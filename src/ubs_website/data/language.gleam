// IMPORTS ---------------------------------------------------------------------

import gleam/option.{type Option, None, Some}

// TYPES -----------------------------------------------------------------------

pub type Language {
  Swedish
  English
}

/// A value that must exist in both languages, such as a general page.
///
pub type Translated(a) {
  Translated(swedish: a, english: a)
}

// CONSTANTS -------------------------------------------------------------------

/// Every language the site is published in, default first.
///
pub const all = [Swedish, English]

// QUERIES ---------------------------------------------------------------------

/// The language's ISO 639-1 code, as used in file names and `lang` attributes.
///
pub fn code(language: Language) -> String {
  case language {
    Swedish -> "sv"
    English -> "en"
  }
}

/// Choose between a Swedish and an English value. Views use this for every
/// user-facing string, so neither language can be forgotten.
///
pub fn pick(language: Language, swedish swedish: a, english english: a) -> a {
  case language {
    Swedish -> swedish
    English -> english
  }
}

pub fn get(translated: Translated(a), language: Language) -> a {
  pick(language, swedish: translated.swedish, english: translated.english)
}

/// The value in the requested language when there is one, otherwise the
/// Swedish value, together with the language actually returned — so the view
/// can mark Swedish text on an English page with `lang="sv"`.
///
pub fn with_fallback(
  language: Language,
  swedish swedish: a,
  english english: Option(a),
) -> #(a, Language) {
  case language, english {
    English, Some(english) -> #(english, English)
    English, None | Swedish, _ -> #(swedish, Swedish)
  }
}
