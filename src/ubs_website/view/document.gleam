// IMPORTS ---------------------------------------------------------------------

import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import ubs_website/data/language.{type Language, English, Swedish}
import ubs_website/data/settings.{type Settings}
import ubs_website/route.{type Route}
import ubs_website/site.{type Site}

// TYPES -----------------------------------------------------------------------

pub type Meta {
  Meta(
    title: String,
    description: String,
    route: Route,
    /// An image for link previews, as a path from the site root. Pages without
    /// one use the logo.
    image: Option(String),
  )
}

// CONSTANTS -------------------------------------------------------------------

const site_name = "Uppsala Blåsarsymfoniker"

const navigation = [
  route.Concerts,
  route.News,
  route.About,
  route.Join,
  route.Booking,
  route.Contact,
]

// VIEW ------------------------------------------------------------------------

/// A complete HTML page: head metadata, header, the given body, and footer.
///
pub fn view(
  site: Site,
  settings: Settings,
  language: Language,
  meta: Meta,
  body: List(Element(a)),
) -> Element(a) {
  html.html([attribute.lang(language.code(language))], [
    head(site, language, meta),
    html.body([attribute.class("flex min-h-screen flex-col")], [
      skip_link(language),
      header(site, language, Some(meta.route)),
      html.main(
        [
          attribute.id("main"),
          attribute.class("mx-auto w-full max-w-5xl flex-1 px-4 py-12"),
        ],
        body,
      ),
      footer(
        site,
        settings,
        language.pick(language, swedish: "Kontakt", english: "Contact"),
      ),
    ]),
  ])
}

/// Markdown rendered to HTML, styled by the `prose` utility.
///
pub fn prose(
  attributes: List(attribute.Attribute(a)),
  html: String,
) -> Element(a) {
  element.unsafe_raw_html(
    "",
    "div",
    [attribute.class("prose"), ..attributes],
    html,
  )
}

/// The page title shown in the browser tab and in link previews.
///
pub fn full_title(meta: Meta) -> String {
  case meta.route {
    route.Home -> site_name
    route.About
    | route.Join
    | route.Booking
    | route.Contact
    | route.Concerts
    | route.Concert(_)
    | route.News
    | route.NewsItem(_) -> meta.title <> " – " <> site_name
  }
}

/// The page GitHub Pages serves for any missing path. It is the same file for
/// both languages, so it speaks both, and every link is absolute.
///
pub fn not_found(site: Site, settings: Settings) -> Element(a) {
  html.html([attribute.lang("sv")], [
    html.head([], [
      html.meta([attribute.charset("utf-8")]),
      html.meta([
        attribute.name("viewport"),
        attribute.content("width=device-width, initial-scale=1"),
      ]),
      html.title([], "Sidan finns inte – " <> site_name),
      html.meta([attribute.name("robots"), attribute.content("noindex")]),
      html.link([
        attribute.rel("icon"),
        attribute.type_("image/svg+xml"),
        attribute.href(route.asset(site, "/images/ubs-logo.svg")),
      ]),
      html.link([
        attribute.rel("stylesheet"),
        attribute.href(route.asset(site, "/css/site.css")),
      ]),
      analytics(site.analytics_token),
    ]),
    html.body([attribute.class("flex min-h-screen flex-col")], [
      header(site, Swedish, None),
      html.main(
        [
          attribute.id("main"),
          attribute.class(
            "mx-auto grid w-full max-w-5xl flex-1 gap-12 px-4 py-12 md:grid-cols-2",
          ),
        ],
        [
          not_found_message(
            site,
            Swedish,
            "Sidan finns inte",
            "Sidan du letar efter finns inte, eller har flyttat.",
            "Till startsidan",
          ),
          not_found_message(
            site,
            English,
            "Page not found",
            "The page you are looking for does not exist, or has moved.",
            "Go to the home page",
          ),
        ],
      ),
      footer(site, settings, "Kontakt · Contact"),
    ]),
  ])
}

fn not_found_message(
  site: Site,
  language: Language,
  title: String,
  message: String,
  link: String,
) -> Element(a) {
  html.div([attribute.lang(language.code(language))], [
    html.h1([attribute.class("mb-4 text-h1 font-bold")], [html.text(title)]),
    html.p([attribute.class("mb-6")], [html.text(message)]),
    html.a(
      [
        attribute.href(route.href(site, route.Home, language)),
        attribute.class("text-primary underline"),
      ],
      [html.text(link)],
    ),
  ])
}

// TRANSLATIONS ----------------------------------------------------------------

/// A note on an English page whose text is only available in Swedish.
///
pub fn fallback_notice(
  language: Language,
  text_language: Language,
) -> Element(a) {
  case language, text_language {
    English, Swedish ->
      html.p([attribute.class("mb-6"), attribute.lang("en")], [
        in_swedish_label(),
      ])
    English, English | Swedish, _ -> element.none()
  }
}

pub fn in_swedish_label() -> Element(a) {
  html.span(
    [
      attribute.lang("en"),
      attribute.class(
        "inline-block self-start rounded-md bg-base-200 px-2 py-1 text-small text-muted",
      ),
    ],
    [html.text("In Swedish")],
  )
}

/// `lang` for text in another language than the page around it.
///
pub fn lang_if_different(
  page_language: Language,
  text_language: Language,
) -> attribute.Attribute(a) {
  case page_language == text_language {
    True -> attribute.none()
    False -> attribute.lang(language.code(text_language))
  }
}

// HEAD ------------------------------------------------------------------------

fn head(site: Site, language: Language, meta: Meta) -> Element(a) {
  let title = full_title(meta)
  let image = case meta.image {
    Some(image) -> site.url <> image
    None -> site.url <> "/images/ubs-logo.png"
  }

  html.head([], [
    html.meta([attribute.charset("utf-8")]),
    html.meta([
      attribute.name("viewport"),
      attribute.content("width=device-width, initial-scale=1"),
    ]),
    html.title([], title),
    html.meta([
      attribute.name("description"),
      attribute.content(meta.description),
    ]),
    html.link([
      attribute.rel("canonical"),
      attribute.href(route.url(site, meta.route, language)),
    ]),
    element.fragment(
      list.map(language.all, fn(other) {
        html.link([
          attribute.rel("alternate"),
          attribute.attribute("hreflang", language.code(other)),
          attribute.href(route.url(site, meta.route, other)),
        ])
      }),
    ),

    // OPEN GRAPH --------------------------------------------------------------
    property("og:site_name", site_name),
    property("og:title", title),
    property("og:description", meta.description),
    property("og:url", route.url(site, meta.route, language)),
    property("og:image", image),
    property("og:type", "website"),
    property(
      "og:locale",
      language.pick(language, swedish: "sv_SE", english: "en_GB"),
    ),

    // ICONS & STYLES ----------------------------------------------------------
    html.link([
      attribute.rel("icon"),
      attribute.type_("image/svg+xml"),
      attribute.href(route.asset(site, "/images/ubs-logo.svg")),
    ]),
    html.link([
      attribute.rel("stylesheet"),
      attribute.href(route.asset(site, "/css/site.css")),
    ]),

    analytics(site.analytics_token),
  ])
}

fn property(name: String, content: String) -> Element(a) {
  html.meta([attribute.attribute("property", name), attribute.content(content)])
}

/// Cloudflare Web Analytics: cookie-free, so no consent banner is needed.
///
fn analytics(token: Option(String)) -> Element(a) {
  case token {
    None -> element.none()
    Some(token) ->
      html.script(
        [
          attribute.attribute("defer", ""),
          attribute.src("https://static.cloudflareinsights.com/beacon.min.js"),
          attribute.attribute(
            "data-cf-beacon",
            "{\"token\": \"" <> token <> "\"}",
          ),
        ],
        "",
      )
  }
}

// HEADER ----------------------------------------------------------------------

fn skip_link(language: Language) -> Element(a) {
  html.a(
    [
      attribute.href("#main"),
      attribute.class(
        "sr-only focus:not-sr-only focus:absolute focus:top-2 focus:left-2 focus:rounded-sm focus:bg-primary focus:px-4 focus:py-2 focus:text-primary-content",
      ),
    ],
    [
      html.text(language.pick(
        language,
        swedish: "Hoppa till innehållet",
        english: "Skip to content",
      )),
    ],
  )
}

fn header(
  site: Site,
  language: Language,
  current: Option(Route),
) -> Element(a) {
  html.header([attribute.class("border-b border-base-300")], [
    html.div(
      [
        attribute.class(
          "mx-auto flex max-w-5xl flex-wrap items-center justify-between gap-4 px-4 py-4",
        ),
      ],
      [
        html.a(
          [
            attribute.href(route.href(site, route.Home, language)),
            attribute.class("flex items-center gap-3"),
          ],
          [
            html.img([
              attribute.src(route.asset(site, "/images/ubs-logo.svg")),
              attribute.alt(""),
              attribute.class("h-12 w-auto"),
            ]),
            html.span([attribute.class("font-display text-h3 font-bold")], [
              html.text(site_name),
            ]),
          ],
        ),
        html.nav(
          [
            attribute.attribute(
              "aria-label",
              language.pick(
                language,
                swedish: "Huvudmeny",
                english: "Main menu",
              ),
            ),
          ],
          [
            html.ul(
              [attribute.class("flex flex-wrap items-center gap-x-6 gap-y-2")],
              list.append(
                list.map(navigation, fn(target) {
                  html.li([], [nav_link(site, language, current, target)])
                }),
                [html.li([], [language_switch(site, language, current)])],
              ),
            ),
          ],
        ),
      ],
    ),
  ])
}

fn nav_link(
  site: Site,
  language: Language,
  current: Option(Route),
  target: Route,
) -> Element(a) {
  let is_current = case current {
    Some(current) -> section(current) == section(target)
    None -> False
  }

  html.a(
    [
      attribute.href(route.href(site, target, language)),
      attribute.class("hover:text-primary"),
      case is_current {
        True -> attribute.attribute("aria-current", "page")
        False -> attribute.none()
      },
      attribute.classes([#("text-primary font-semibold", is_current)]),
    ],
    [html.text(nav_label(target, language))],
  )
}

/// Concert and news pages highlight their section in the navigation.
///
fn section(route: Route) -> Route {
  case route {
    route.Concert(_) -> route.Concerts
    route.NewsItem(_) -> route.News
    route.Home
    | route.About
    | route.Join
    | route.Booking
    | route.Contact
    | route.Concerts
    | route.News -> route
  }
}

fn nav_label(target: Route, language: Language) -> String {
  case target {
    route.Home -> language.pick(language, swedish: "Hem", english: "Home")
    route.Concerts | route.Concert(_) ->
      language.pick(language, swedish: "Konserter", english: "Concerts")
    route.News | route.NewsItem(_) ->
      language.pick(language, swedish: "Nyheter", english: "News")
    route.About -> language.pick(language, swedish: "Om oss", english: "About")
    route.Join ->
      language.pick(language, swedish: "Bli medlem", english: "Join")
    route.Booking ->
      language.pick(language, swedish: "Boka oss", english: "Book us")
    route.Contact ->
      language.pick(language, swedish: "Kontakt", english: "Contact")
  }
}

fn language_switch(
  site: Site,
  language: Language,
  current: Option(Route),
) -> Element(a) {
  let #(other, label) = case language {
    Swedish -> #(English, "English")
    English -> #(Swedish, "Svenska")
  }

  html.a(
    [
      attribute.href(route.href(site, option.unwrap(current, route.Home), other)),
      attribute.lang(language.code(other)),
      attribute.attribute("hreflang", language.code(other)),
      attribute.class(
        "rounded-sm border border-base-300 px-3 py-1 text-small hover:border-primary hover:text-primary",
      ),
    ],
    [html.text(label)],
  )
}

// FOOTER ----------------------------------------------------------------------

/// The site footer. `heading` names the contact column in the page's language,
/// or in both on the bilingual 404 page.
///
fn footer(site: Site, settings: Settings, heading: String) -> Element(a) {
  html.footer([attribute.class("bg-neutral text-neutral-content")], [
    html.div(
      [
        attribute.class(
          "mx-auto flex max-w-5xl flex-col gap-8 px-4 py-12 md:flex-row md:justify-between",
        ),
      ],
      [
        html.div([attribute.class("flex items-center gap-3")], [
          html.img([
            attribute.src(route.asset(site, "/images/ubs-logo-white.svg")),
            attribute.alt(""),
            attribute.class("h-10 w-auto"),
          ]),
          html.span([attribute.class("font-display text-h3")], [
            html.text(site_name),
          ]),
        ]),
        html.div([attribute.class("flex flex-col gap-2")], [
          html.h2([attribute.class("label-type font-body text-muted-inverse")], [
            html.text(heading),
          ]),
          html.a(
            [
              attribute.href("mailto:" <> settings.email),
              attribute.class("hover:underline"),
            ],
            [html.text(settings.email)],
          ),
          social_link(settings.facebook, "Facebook"),
          social_link(settings.instagram, "Instagram"),
        ]),
      ],
    ),
  ])
}

fn social_link(url: Option(String), label: String) -> Element(a) {
  case url {
    Some(url) ->
      html.a([attribute.href(url), attribute.class("hover:underline")], [
        html.text(label),
      ])
    None -> element.none()
  }
}
