// IMPORTS ---------------------------------------------------------------------

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import ubs_website/data/concert.{type Concert, type Performances}
import ubs_website/data/language.{type Language}
import ubs_website/route
import ubs_website/site.{type Site}
import ubs_website/view/date
import ubs_website/view/document.{type Meta, Meta}

// PAGES -----------------------------------------------------------------------

/// The concert list: upcoming soonest first, then past ones by year.
///
pub fn list_view(
  site: Site,
  language: Language,
  concerts: List(Concert),
) -> List(Element(a)) {
  let upcoming = concert.upcoming(concerts, site.today)
  let past = concert.past(concerts, site.today)

  [
    html.h1([attribute.class("mb-8 text-h1 font-bold")], [
      html.text(title(language)),
    ]),
    html.section([attribute.class("mb-16")], [
      html.h2([attribute.class("mb-6 text-h2 font-bold")], [
        html.text(language.pick(
          language,
          swedish: "Kommande",
          english: "Upcoming",
        )),
      ]),
      case upcoming {
        [] ->
          html.p([attribute.class("text-muted")], [
            html.text(language.pick(
              language,
              swedish: "Inga kommande konserter just nu – håll utkik!",
              english: "No upcoming concerts right now – stay tuned!",
            )),
          ])
        [next, ..later] ->
          html.div([attribute.class("flex flex-col gap-6")], [
            featured(site, language, next),
            case later {
              [] -> element.none()
              _ -> cards(site, language, later)
            },
          ])
      },
    ]),
    case past {
      [] -> element.none()
      _ ->
        html.section([], [
          html.h2([attribute.class("mb-6 text-h2 font-bold")], [
            html.text(language.pick(
              language,
              swedish: "Tidigare konserter",
              english: "Past concerts",
            )),
          ]),
          element.fragment(
            list.map(by_year(past), fn(group) {
              let #(year, concerts) = group
              html.div([attribute.class("mb-8")], [
                html.h3([attribute.class("mb-4 text-h3")], [
                  html.text(int.to_string(year)),
                ]),
                cards(site, language, concerts),
              ])
            }),
          ),
        ])
    },
  ]
}

/// One concert: every performance, the venue, tickets while it is upcoming,
/// the image, and the description.
///
/// The image and the description share the reading column, with the facts
/// beside them. On narrow screens the facts come between the image and the
/// description.
///
pub fn detail_view(
  site: Site,
  language: Language,
  concert: Concert,
) -> List(Element(a)) {
  let #(text, text_language) =
    language.with_fallback(
      language,
      swedish: concert.swedish,
      english: concert.english,
    )

  [
    html.article([], [
      html.p([attribute.class("mb-4")], [
        html.a(
          [
            attribute.href(route.href(site, route.Concerts, language)),
            attribute.class("text-small text-primary hover:underline"),
          ],
          [
            html.text(language.pick(
              language,
              swedish: "← Alla konserter",
              english: "← All concerts",
            )),
          ],
        ),
      ]),
      html.h1(
        [
          attribute.class("mb-8 text-h1 font-bold"),
          document.lang_if_different(language, text_language),
        ],
        [html.text(text.title)],
      ),
      document.fallback_notice(language, text_language),
      html.div(
        [
          attribute.class(
            "grid gap-8 md:grid-cols-[minmax(0,var(--container-prose))_16rem] md:justify-between",
          ),
        ],
        [
          image(site, concert.image, text.title, Eager, Whole),
          html.aside(
            [
              attribute.class(
                "self-start rounded-lg bg-base-200 p-6 md:sticky md:top-8 md:col-start-2 md:row-start-1",
              ),
              // Beside both the image and the description, when there is an
              // image above the description.
              attribute.classes([
                #("md:row-span-2", option.is_some(concert.image)),
              ]),
            ],
            [facts(site, language, concert)],
          ),
          document.prose(
            [document.lang_if_different(language, text_language)],
            text.body,
          ),
        ],
      ),
    ]),
  ]
}

/// The next concert, shown large on the home page.
///
pub fn featured(
  site: Site,
  language: Language,
  concert: Concert,
) -> Element(a) {
  let #(text, text_language) =
    language.with_fallback(
      language,
      swedish: concert.swedish,
      english: concert.english,
    )
  let href = route.href(site, route.Concert(concert.slug), language)

  html.article(
    [
      attribute.class(
        "grid gap-8 overflow-hidden rounded-lg border border-base-300 bg-card p-6 md:grid-cols-[3fr_2fr]",
      ),
    ],
    [
      image(site, concert.image, text.title, Eager, Whole),
      html.div([attribute.class("flex flex-col gap-4")], [
        case text_language == language {
          True -> element.none()
          False -> document.in_swedish_label()
        },
        html.h3(
          [
            attribute.class("text-h2 font-bold"),
            document.lang_if_different(language, text_language),
          ],
          [
            html.a(
              [attribute.href(href), attribute.class("hover:text-primary")],
              [
                html.text(text.title),
              ],
            ),
          ],
        ),
        case text.summary {
          Some(summary) ->
            html.p([document.lang_if_different(language, text_language)], [
              html.text(summary),
            ])
          None -> element.none()
        },
        facts(site, language, concert),
        html.a(
          [attribute.href(href), attribute.class("text-primary underline")],
          [
            html.text(language.pick(
              language,
              swedish: "Läs mer om konserten",
              english: "More about the concert",
            )),
          ],
        ),
      ]),
    ],
  )
}

pub fn list_meta(language: Language) -> Meta {
  Meta(
    title: title(language),
    description: language.pick(
      language,
      swedish: "Kommande och tidigare konserter med Uppsala Blåsarsymfoniker.",
      english: "Upcoming and past concerts with Uppsala Blåsarsymfoniker.",
    ),
    route: route.Concerts,
    image: None,
  )
}

pub fn detail_meta(language: Language, concert: Concert) -> Meta {
  let #(text, _) =
    language.with_fallback(
      language,
      swedish: concert.swedish,
      english: concert.english,
    )

  Meta(
    title: text.title,
    description: option.unwrap(text.summary, ""),
    route: route.Concert(concert.slug),
    image: concert.image,
  )
}

fn title(language: Language) -> String {
  language.pick(language, swedish: "Konserter", english: "Concerts")
}

// COMPONENTS ------------------------------------------------------------------

/// Concert cards in a grid, for the concert list and the home page.
///
pub fn cards(
  site: Site,
  language: Language,
  concerts: List(Concert),
) -> Element(a) {
  html.ul(
    [attribute.class("grid gap-6 sm:grid-cols-2 lg:grid-cols-3")],
    list.map(concerts, fn(concert) {
      html.li([], [card(site, language, concert)])
    }),
  )
}

fn card(site: Site, language: Language, concert: Concert) -> Element(a) {
  let #(text, text_language) =
    language.with_fallback(
      language,
      swedish: concert.swedish,
      english: concert.english,
    )

  html.article(
    [
      attribute.class(
        "flex h-full flex-col overflow-hidden rounded-lg border border-base-300 bg-card",
      ),
    ],
    [
      image(site, concert.image, "", Lazy, Framed),
      html.div([attribute.class("flex flex-1 flex-col gap-2 p-4")], [
        first_performance(concert.performances, language),
        html.h3(
          [
            attribute.class("text-h3 font-bold"),
            document.lang_if_different(language, text_language),
          ],
          [
            html.a(
              [
                attribute.href(route.href(
                  site,
                  route.Concert(concert.slug),
                  language,
                )),
                attribute.class("hover:text-primary"),
              ],
              [html.text(text.title)],
            ),
          ],
        ),
        html.p([attribute.class("text-small text-muted")], [
          html.text(concert.venue),
        ]),
        case text_language == language {
          True -> element.none()
          False -> document.in_swedish_label()
        },
      ]),
    ],
  )
}

fn facts(site: Site, language: Language, concert: Concert) -> Element(a) {
  let status = concert.status(concert, site.today)

  html.dl([attribute.class("flex flex-col gap-4")], [
    html.div([], [
      html.dt([attribute.class("label-type text-muted")], [
        html.text(language.pick(language, swedish: "När", english: "When")),
      ]),
      html.dd(
        [],
        list.map(concert.performance_list(concert), fn(performance) {
          html.p([], [
            date.date_time_view(performance.date, performance.time, language),
          ])
        }),
      ),
    ]),
    html.div([], [
      html.dt([attribute.class("label-type text-muted")], [
        html.text(language.pick(language, swedish: "Var", english: "Where")),
      ]),
      html.dd([], [html.text(concert.venue)]),
    ]),
    case status, concert.ticket_url {
      concert.Upcoming, Some(url) ->
        html.div([], [
          html.a(
            [
              attribute.href(url),
              attribute.class(
                "inline-block rounded-sm bg-primary px-5 py-2 font-semibold text-primary-content hover:bg-primary-hover",
              ),
            ],
            [
              html.text(language.pick(
                language,
                swedish: "Köp biljetter",
                english: "Buy tickets",
              )),
            ],
          ),
        ])
      concert.Upcoming, None | concert.Past, _ -> element.none()
    },
  ])
}

/// The first date, noting when the concert runs over more days.
///
fn first_performance(
  performances: Performances,
  language: Language,
) -> Element(a) {
  let first = performances.first

  html.p([attribute.class("label-type text-primary")], [
    date.view(first.date, language),
    case list.any(performances.rest, fn(other) { other.date != first.date }) {
      True ->
        html.text(language.pick(
          language,
          swedish: " med flera",
          english: " and more",
        ))
      False -> element.none()
    },
  ])
}

type Loading {
  Eager
  Lazy
}

/// Concert images are mostly posters with text up to the edges, in any
/// shape, so they are never cropped.
///
type Fit {
  /// The whole image at its own shape, kept from growing taller than the
  /// screen.
  Whole
  /// The whole image inside a 16:9 frame, so cards in a grid line up. The
  /// card's own rounded corners clip it.
  Framed
}

fn image(
  site: Site,
  path: Option(String),
  alt: String,
  loading: Loading,
  fit: Fit,
) -> Element(a) {
  case path {
    Some(path) ->
      html.img([
        attribute.src(route.asset(site, path)),
        attribute.alt(alt),
        attribute.attribute("loading", case loading {
          Eager -> "eager"
          Lazy -> "lazy"
        }),
        attribute.class(case fit {
          Whole -> "h-auto max-h-160 w-auto max-w-full rounded-md"
          Framed -> "aspect-video w-full bg-neutral object-contain"
        }),
      ])
    None -> element.none()
  }
}

fn by_year(concerts: List(Concert)) -> List(#(Int, List(Concert))) {
  list.chunk(concerts, year)
  |> list.filter_map(fn(group) {
    case group {
      [first, ..] -> Ok(#(year(first), group))
      [] -> Error(Nil)
    }
  })
}

fn year(concert: Concert) -> Int {
  concert.performances.first.date.year
}
