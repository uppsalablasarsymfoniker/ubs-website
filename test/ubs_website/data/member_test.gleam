import gleam/list
import ubs_website/data/member

pub fn every_section_has_a_unique_key_test() -> Nil {
  list.each(member.sections, fn(section) {
    assert member.section_from_key(member.section_to_key(section))
      == Ok(section)
  })
}

pub fn unknown_section_key_test() -> Nil {
  assert member.section_from_key("kazoo") == Error(Nil)
}
