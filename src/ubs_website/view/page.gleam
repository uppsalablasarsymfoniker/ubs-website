// IMPORTS ---------------------------------------------------------------------

import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/uri
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import ubs_website/data/concert.{type Concert}
import ubs_website/data/entry.{type Text}
import ubs_website/data/language.{type Language}
import ubs_website/data/news.{type NewsItem}
import ubs_website/data/settings.{type Settings}
import ubs_website/route.{type Route}
import ubs_website/site.{type Site}
import ubs_website/view/concert as concert_view
import ubs_website/view/document.{type Meta, Meta}
import ubs_website/view/news as news_view

// VIEW ------------------------------------------------------------------------

/// A general page: its title, its Markdown body, and anything the page adds
/// after the body.
///
pub fn view(text: Text, after: List(Element(a))) -> List(Element(a)) {
  [
    html.h1([attribute.class("mb-8 text-h1 font-bold")], [html.text(text.title)]),
    document.prose([], text.body),
    ..after
  ]
}

/// The home page: the orchestra's name set large, its introduction, and the
/// sections after it. There is no photo, so the type carries the page.
///
pub fn home_view(text: Text, after: List(Element(a))) -> List(Element(a)) {
  [
    html.div(
      [attribute.class("mb-6 h-1 w-12 bg-accent"), attribute.aria_hidden(True)],
      [],
    ),
    html.h1([attribute.class("mb-8 text-h1 font-bold md:text-display")], [
      html.text(text.title),
    ]),
    document.prose([], text.body),
    ..after
  ]
}

pub fn meta(text: Text, route: Route) -> Meta {
  Meta(
    title: text.title,
    description: option.unwrap(text.summary, ""),
    route:,
    image: None,
  )
}

/// A button that opens an email to the orchestra.
///
pub fn email_button(settings: Settings, language: Language) -> Element(a) {
  html.p([attribute.class("mt-8")], [
    html.a(
      [
        attribute.href("mailto:" <> settings.email),
        attribute.class(
          "inline-block rounded-sm bg-primary px-5 py-2 font-semibold text-primary-content hover:bg-primary-hover",
        ),
      ],
      [
        html.text(language.pick(
          language,
          swedish: "Mejla oss",
          english: "Email us",
        )),
      ],
    ),
  ])
}

/// Contact details from the site settings.
///
pub fn contact_details(settings: Settings, language: Language) -> Element(a) {
  html.dl(
    [
      attribute.class(
        "mt-8 grid items-baseline gap-x-8 gap-y-2 sm:grid-cols-[auto_1fr]",
      ),
    ],
    [
      detail(
        language.pick(language, swedish: "E-post", english: "Email"),
        Some(
          html.a(
            [
              attribute.href("mailto:" <> settings.email),
              attribute.class("text-primary underline"),
            ],
            [html.text(settings.email)],
          ),
        ),
      ),
      detail(
        language.pick(language, swedish: "Telefon", english: "Phone"),
        option.map(settings.phone, html.text),
      ),
      detail(
        language.pick(
          language,
          swedish: "Postadress",
          english: "Postal address",
        ),
        option.map(settings.postal_address, fn(address) {
          html.span([attribute.class("whitespace-pre-line")], [
            html.text(address),
          ])
        }),
      ),
      detail("Facebook", option.map(settings.facebook, account_link(_, ""))),
      detail("Instagram", option.map(settings.instagram, account_link(_, "@"))),
    ],
  )
}

fn detail(label: String, value: Option(Element(a))) -> Element(a) {
  case value {
    Some(value) ->
      element.fragment([
        html.dt([attribute.class("label-type text-muted")], [html.text(label)]),
        html.dd([], [value]),
      ])
    None -> element.none()
  }
}

fn account_link(url: String, prefix: String) -> Element(a) {
  html.a([attribute.href(url), attribute.class("text-primary underline")], [
    html.text(account_name(url, prefix)),
  ])
}

/// The account name from a profile URL: its last path segment, so
/// `https://www.instagram.com/ubsymfoniker/` with prefix "@" is
/// "@ubsymfoniker". Editors paste these URLs into the CMS, so any URL that
/// doesn't look like a plain profile address (a query string, a file name
/// like `profile.php`, no path) is shown whole rather than guessed at.
///
pub fn account_name(url: String, prefix: String) -> String {
  case uri.parse(url) {
    Ok(uri.Uri(query: None, path:, ..)) ->
      case list.last(uri.path_segments(path)) {
        Ok(name) ->
          case string.contains(name, ".") {
            True -> url
            False -> prefix <> name
          }
        Error(Nil) -> url
      }
    Ok(uri.Uri(query: Some(_), ..)) | Error(Nil) -> url
  }
}

// HOME ------------------------------------------------------------------------

/// What the home page shows after its introduction: the next concert, a few
/// more upcoming ones, the latest news, and ways to get involved.
///
pub fn home_sections(
  site: Site,
  language: Language,
  concerts: List(Concert),
  news: List(NewsItem),
) -> List(Element(a)) {
  let upcoming = concert.upcoming(concerts, site.today)

  [
    case upcoming {
      [next, ..rest] ->
        html.section([attribute.class("mt-16")], [
          section_heading(language.pick(
            language,
            swedish: "Nästa konsert",
            english: "Next concert",
          )),
          concert_view.featured(site, language, next),
          case list.take(rest, 3) {
            [] -> element.none()
            more ->
              html.div([attribute.class("mt-6")], [
                concert_view.cards(site, language, more),
              ])
          },
          more_link(
            route.href(site, route.Concerts, language),
            language.pick(
              language,
              swedish: "Alla konserter",
              english: "All concerts",
            ),
          ),
        ])
      [] -> element.none()
    },
    case list.take(news, 3) {
      [] -> element.none()
      latest ->
        html.section([attribute.class("mt-16")], [
          section_heading(language.pick(
            language,
            swedish: "Nyheter",
            english: "News",
          )),
          news_view.items_view(site, language, latest),
          more_link(
            route.href(site, route.News, language),
            language.pick(
              language,
              swedish: "Alla nyheter",
              english: "All news",
            ),
          ),
        ])
    },
    html.section([attribute.class("mt-16 grid gap-6 md:grid-cols-2")], [
      invitation(
        route.href(site, route.Join, language),
        language.pick(
          language,
          swedish: "Spela med oss",
          english: "Play with us",
        ),
        language.pick(
          language,
          swedish: "Vi repeterar varje måndag i Uppsala. Berätta om dig själv och vad du spelar.",
          english: "We rehearse every Monday in Uppsala. Tell us about yourself and what you play.",
        ),
        language.pick(
          language,
          swedish: "Så blir du medlem",
          english: "How to join",
        ),
      ),
      invitation(
        route.href(site, route.Booking, language),
        language.pick(language, swedish: "Boka oss", english: "Book us"),
        language.pick(
          language,
          swedish: "Omkring 50 musiker till konserter, festivaler och evenemang.",
          english: "Around 50 musicians for concerts, festivals, and events.",
        ),
        language.pick(
          language,
          swedish: "Boka orkestern",
          english: "Book the orchestra",
        ),
      ),
    ]),
  ]
}

fn section_heading(title: String) -> Element(a) {
  html.h2([attribute.class("mb-6 text-h2 font-bold")], [html.text(title)])
}

fn more_link(href: String, label: String) -> Element(a) {
  html.p([attribute.class("mt-6")], [
    html.a([attribute.href(href), attribute.class("text-primary underline")], [
      html.text(label <> " →"),
    ]),
  ])
}

fn invitation(
  href: String,
  title: String,
  description: String,
  action: String,
) -> Element(a) {
  html.a(
    [
      attribute.href(href),
      attribute.class(
        "group flex flex-col gap-2 rounded-lg bg-neutral p-6 text-neutral-content",
      ),
    ],
    [
      html.span(
        [
          attribute.class("font-display text-h3 font-bold"),
        ],
        [html.text(title)],
      ),
      html.span([attribute.class("text-muted-inverse")], [
        html.text(description),
      ]),
      html.span(
        [attribute.class("font-semibold text-accent group-hover:underline")],
        [
          html.text(action <> " "),
          html.span([attribute.aria_hidden(True)], [html.text("→")]),
        ],
      ),
    ],
  )
}
