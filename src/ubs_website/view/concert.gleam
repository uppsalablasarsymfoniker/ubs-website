// IMPORTS ---------------------------------------------------------------------

import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import ubs_website/data/concert.{type Concert, type Performance}
import ubs_website/data/entry.{type Text}
import ubs_website/data/language.{type Language}
import ubs_website/data/site.{type Site}
import ubs_website/route
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
    html.h1([attribute.class("mb-12 text-h1 font-bold")], [
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
        _ -> cards(site, language, upcoming)
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
    html.article([document.lang_if_different(language, text_language)], [
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
      html.h1([attribute.class("mb-6 text-h1 font-bold")], [
        html.text(text.title),
      ]),
      document.fallback_notice(language, text_language),
      html.div([attribute.class("mb-8 grid gap-8 md:grid-cols-[2fr_3fr]")], [
        facts(site, language, concert),
        image(site, concert.image, text.title, Eager),
      ]),
      document.prose(text.body),
    ]),
  ]
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
    description: summary(text),
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
      image(site, concert.image, "", Lazy),
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
        list.map(concert.performances, fn(performance) {
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

fn first_performance(
  performances: List(Performance),
  language: Language,
) -> Element(a) {
  case performances {
    [first, ..rest] ->
      html.p([attribute.class("label-type text-primary")], [
        date.view(first.date, language),
        case list.any(rest, fn(other) { other.date != first.date }) {
          True ->
            html.text(language.pick(
              language,
              swedish: " med flera",
              english: " and more",
            ))
          False -> element.none()
        },
      ])
    [] -> element.none()
  }
}

type Loading {
  Eager
  Lazy
}

fn image(
  site: Site,
  path: Option(String),
  alt: String,
  loading: Loading,
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
        attribute.class("aspect-[16/10] w-full rounded-md object-cover"),
      ])
    None -> element.none()
  }
}

fn summary(text: Text) -> String {
  option.unwrap(text.summary, "")
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
  case concert.performances {
    [first, ..] -> first.date.year
    [] -> 0
  }
}
