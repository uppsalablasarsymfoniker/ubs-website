// IMPORTS ---------------------------------------------------------------------

import envoy
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/time/calendar.{type Date}
import gleam/time/timestamp
import gleam/uri

// TYPES -----------------------------------------------------------------------

/// Where the site is published and when it is built.
///
pub type Site {
  Site(
    /// The public address, including any path the site lives under,
    /// without a trailing slash: `https://example.org/ubs-website`.
    url: String,
    /// The path part of `url`, prefixed to every internal link: `/ubs-website`,
    /// or `""` when the site lives at the domain root.
    base_path: String,
    /// The Cloudflare Web Analytics site token. Without one, no analytics
    /// script is added.
    analytics_token: Option(String),
    /// The build date, which decides whether a concert is upcoming.
    today: Date,
  )
}

// CONSTANTS -------------------------------------------------------------------

const local_url = "http://localhost:8000"

// CONSTRUCTORS ----------------------------------------------------------------

/// Read the site's address from `SITE_URL` and the analytics token from
/// `CLOUDFLARE_ANALYTICS_TOKEN`. Builds without `SITE_URL` are for local
/// preview at the domain root.
///
pub fn from_environment() -> Site {
  let url = case envoy.get("SITE_URL") {
    Ok(url) -> url
    Error(Nil) -> local_url
  }
  let analytics_token = case envoy.get("CLOUDFLARE_ANALYTICS_TOKEN") {
    Ok("") | Error(Nil) -> None
    Ok(token) -> Some(token)
  }
  let #(today, _) =
    timestamp.system_time()
    |> timestamp.to_calendar(calendar.local_offset())

  new(url:, analytics_token:, today:)
}

pub fn new(
  url url: String,
  analytics_token analytics_token: Option(String),
  today today: Date,
) -> Site {
  let url = trim_trailing_slash(url)
  let base_path = case uri.parse(url) {
    Ok(parsed) -> trim_trailing_slash(parsed.path)
    Error(Nil) -> ""
  }

  Site(url:, base_path:, analytics_token:, today:)
}

fn trim_trailing_slash(path: String) -> String {
  case string.ends_with(path, "/") {
    True -> trim_trailing_slash(string.drop_end(path, 1))
    False -> path
  }
}
