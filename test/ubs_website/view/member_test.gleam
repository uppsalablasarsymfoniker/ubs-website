import gleam/option.{None, Some}
import gleam/string
import lustre/element
import ubs_website/data/language.{English, Swedish}
import ubs_website/data/member.{Member}
import ubs_website/view/member as member_view

pub fn empty_list_shows_nothing_test() {
  assert element.to_string(member_view.view(Swedish, [])) == ""
}

pub fn sections_in_orchestra_order_test() {
  let html =
    member_view.view(English, [
      Member("Tuba Player", member.Tuba, None),
      Member("Flute Player", member.Flute, Some("solo")),
    ])
    |> element.to_string

  let assert Ok(#(before_tuba, _)) = string.split_once(html, "Tuba Player")
  assert string.contains(before_tuba, "Flute Player")
  assert string.contains(html, " – solo")
}
