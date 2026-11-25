// IMPORTS ---------------------------------------------------------------------

import gleam/list
import gleam/option.{None, Some}
import lustre/attribute
import lustre/element.{type Element}
import lustre/element/html
import ubs_website/data/language.{type Language}
import ubs_website/data/member.{type Member, type Section}

// VIEW ------------------------------------------------------------------------

/// The member list, grouped by section in orchestra order. Nothing is shown
/// until at least one member is listed.
///
pub fn view(language: Language, members: List(Member)) -> Element(a) {
  let groups =
    list.filter_map(member.sections, fn(section) {
      case list.filter(members, fn(member) { member.section == section }) {
        [] -> Error(Nil)
        in_section -> Ok(#(section, in_section))
      }
    })

  case groups {
    [] -> element.none()
    _ ->
      html.section([attribute.class("mt-16")], [
        html.h2([attribute.class("mb-6 text-h2 font-bold")], [
          html.text(language.pick(
            language,
            swedish: "Våra musiker",
            english: "Our musicians",
          )),
        ]),
        html.div(
          [attribute.class("grid gap-8 sm:grid-cols-2 lg:grid-cols-3")],
          list.map(groups, fn(group) {
            let #(section, members) = group
            html.div([], [
              html.h3(
                [attribute.class("label-type mb-2 font-body text-muted")],
                [
                  html.text(section_name(section, language)),
                ],
              ),
              html.ul(
                [],
                list.map(members, fn(member) {
                  html.li([], [
                    html.text(member.name),
                    case member.role {
                      Some(role) ->
                        html.span([attribute.class("text-small text-muted")], [
                          html.text(" – " <> role),
                        ])
                      None -> element.none()
                    },
                  ])
                }),
              ),
            ])
          }),
        ),
      ])
  }
}

fn section_name(section: Section, language: Language) -> String {
  case section {
    member.Conductor ->
      language.pick(language, swedish: "Dirigent", english: "Conductor")
    member.Flute -> language.pick(language, swedish: "Flöjt", english: "Flute")
    member.Oboe -> language.pick(language, swedish: "Oboe", english: "Oboe")
    member.Bassoon ->
      language.pick(language, swedish: "Fagott", english: "Bassoon")
    member.Clarinet ->
      language.pick(language, swedish: "Klarinett", english: "Clarinet")
    member.Saxophone ->
      language.pick(language, swedish: "Saxofon", english: "Saxophone")
    member.Horn -> language.pick(language, swedish: "Horn", english: "Horn")
    member.Trumpet ->
      language.pick(
        language,
        swedish: "Trumpet och kornett",
        english: "Trumpet and cornet",
      )
    member.Trombone ->
      language.pick(language, swedish: "Trombon", english: "Trombone")
    member.Euphonium ->
      language.pick(language, swedish: "Euphonium", english: "Euphonium")
    member.Tuba -> language.pick(language, swedish: "Tuba", english: "Tuba")
    member.DoubleBass ->
      language.pick(language, swedish: "Kontrabas", english: "Double bass")
    member.Percussion ->
      language.pick(language, swedish: "Slagverk", english: "Percussion")
  }
}
