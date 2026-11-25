// IMPORTS ---------------------------------------------------------------------

import gleam/list
import gleam/option.{None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import ubs_website/data/language.{type Language}
import ubs_website/data/news.{type NewsItem}
import ubs_website/data/site.{type Site}
import ubs_website/route
import ubs_website/view/date
import ubs_website/view/document.{type Meta, Meta}

// PAGES -----------------------------------------------------------------------

pub fn list_view(
  site: Site,
  language: Language,
  items: List(NewsItem),
) -> List(Element(a)) {
  [
    html.h1([attribute.class("mb-12 text-h1 font-bold")], [
      html.text(title(language)),
    ]),
    items_view(site, language, items),
  ]
}

pub fn detail_view(
  site: Site,
  language: Language,
  item: NewsItem,
) -> List(Element(a)) {
  let #(text, text_language) =
    language.with_fallback(
      language,
      swedish: item.swedish,
      english: item.english,
    )

  [
    html.article([], [
      html.p([attribute.class("mb-4")], [
        html.a(
          [
            attribute.href(route.href(site, route.News, language)),
            attribute.class("text-small text-primary hover:underline"),
          ],
          [
            html.text(language.pick(
              language,
              swedish: "← Alla nyheter",
              english: "← All news",
            )),
          ],
        ),
      ]),
      html.p([attribute.class("label-type mb-2 text-primary")], [
        date.view(item.date, language),
      ]),
      html.h1(
        [
          attribute.class("mb-6 text-h1 font-bold"),
          document.lang_if_different(language, text_language),
        ],
        [html.text(text.title)],
      ),
      document.fallback_notice(language, text_language),
      case item.image {
        Some(image) ->
          html.img([
            attribute.src(route.asset(site, image)),
            attribute.alt(""),
            attribute.class("mb-8 w-full max-w-3xl rounded-md"),
          ])
        None -> element.none()
      },
      document.prose(
        [document.lang_if_different(language, text_language)],
        text.body,
      ),
    ]),
  ]
}

pub fn list_meta(language: Language) -> Meta {
  Meta(
    title: title(language),
    description: language.pick(
      language,
      swedish: "Nyheter från Uppsala Blåsarsymfoniker.",
      english: "News from Uppsala Blåsarsymfoniker.",
    ),
    route: route.News,
    image: None,
  )
}

pub fn detail_meta(language: Language, item: NewsItem) -> Meta {
  let #(text, _) =
    language.with_fallback(
      language,
      swedish: item.swedish,
      english: item.english,
    )

  Meta(
    title: text.title,
    description: option.unwrap(text.summary, ""),
    route: route.NewsItem(item.slug),
    image: item.image,
  )
}

fn title(language: Language) -> String {
  language.pick(language, swedish: "Nyheter", english: "News")
}

// COMPONENTS ------------------------------------------------------------------

/// News items with date, title, and summary, newest first. Used on the news
/// page and the home page.
///
pub fn items_view(
  site: Site,
  language: Language,
  items: List(NewsItem),
) -> Element(a) {
  html.ul(
    [attribute.class("flex flex-col gap-8")],
    list.map(items, fn(item) {
      let #(text, text_language) =
        language.with_fallback(
          language,
          swedish: item.swedish,
          english: item.english,
        )

      html.li([attribute.class("flex max-w-3xl flex-col gap-2")], [
        html.p([attribute.class("label-type text-primary")], [
          date.view(item.date, language),
        ]),
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
                  route.NewsItem(item.slug),
                  language,
                )),
                attribute.class("hover:text-primary"),
              ],
              [html.text(text.title)],
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
        case text_language == language {
          True -> element.none()
          False -> document.in_swedish_label()
        },
      ])
    }),
  )
}
