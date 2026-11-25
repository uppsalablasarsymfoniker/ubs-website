// IMPORTS ---------------------------------------------------------------------

import gleam/option.{type Option, None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import ubs_website/data/entry.{type Text}
import ubs_website/data/language.{type Language}
import ubs_website/data/settings.{type Settings}
import ubs_website/route.{type Route}
import ubs_website/view/document.{type Meta, Meta}

// VIEW ------------------------------------------------------------------------

/// A general page: its title, its Markdown body, and anything the page adds
/// after the body.
///
pub fn view(text: Text, after: List(Element(a))) -> List(Element(a)) {
  [
    html.h1([attribute.class("mb-8 text-h1 font-bold")], [html.text(text.title)]),
    document.prose(text.body),
    ..after
  ]
}

pub fn meta(text: Text, route: Route) -> Meta {
  Meta(
    title: text.title,
    description: description(text.summary),
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
    [attribute.class("mt-8 grid gap-x-8 gap-y-2 sm:grid-cols-[auto_1fr]")],
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
      detail("Facebook", option.map(settings.facebook, external_link)),
      detail("Instagram", option.map(settings.instagram, external_link)),
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

fn external_link(url: String) -> Element(a) {
  html.a([attribute.href(url), attribute.class("text-primary underline")], [
    html.text(url),
  ])
}

fn description(summary: Option(String)) -> String {
  case summary {
    Some(summary) -> summary
    None -> ""
  }
}
