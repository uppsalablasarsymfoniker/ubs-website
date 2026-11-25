// IMPORTS ---------------------------------------------------------------------

import gleam/option.{type Option}
import gleam/result
import ubs_website/data/entry
import ubs_website/error.{type Error}

// TYPES -----------------------------------------------------------------------

/// Site-wide contact details, shown in the footer and on the contact page.
///
pub type Settings {
  Settings(
    email: String,
    phone: Option(String),
    postal_address: Option(String),
    facebook: Option(String),
    instagram: Option(String),
  )
}

// CONSTRUCTORS ----------------------------------------------------------------

pub fn load(path: String) -> Result(Settings, Error) {
  use data <- result.try(entry.read_data(path))
  use email <- result.try(entry.string(data, "email"))
  use phone <- result.try(entry.optional_string(data, "phone"))
  use postal_address <- result.try(entry.optional_string(data, "postal_address"))
  use facebook <- result.try(entry.optional_string(data, "facebook"))
  use instagram <- result.try(entry.optional_string(data, "instagram"))

  Ok(Settings(email:, phone:, postal_address:, facebook:, instagram:))
}
