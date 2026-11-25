import gleam/option.{None, Some}
import ubs_website/data/language.{English, Swedish}

pub fn english_page_uses_english_when_translated_test() -> Nil {
  assert language.with_fallback(English, swedish: "Hej", english: Some("Hi"))
    == #("Hi", English)
}

pub fn english_page_falls_back_to_swedish_test() -> Nil {
  assert language.with_fallback(English, swedish: "Hej", english: None)
    == #("Hej", Swedish)
}

pub fn swedish_page_always_uses_swedish_test() -> Nil {
  assert language.with_fallback(Swedish, swedish: "Hej", english: Some("Hi"))
    == #("Hej", Swedish)
}
