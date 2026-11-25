// IMPORTS ---------------------------------------------------------------------

import gleam/string
import ubs_website/data/language.{type Language, English, Swedish}
import ubs_website/data/site.{type Site}

// TYPES -----------------------------------------------------------------------

/// Every page on the site. Each route exists in both languages, at the paths
/// listed in `docs/plan.md`.
///
pub type Route {
  Home
  About
  Join
  Booking
  Contact
  Concerts
  Concert(slug: String)
  News
  NewsItem(slug: String)
}

// QUERIES ---------------------------------------------------------------------

/// The route's path from the site root, always starting and ending with `/`.
///
pub fn path(route: Route, language: Language) -> String {
  let prefix = case language {
    Swedish -> "/"
    English -> "/en/"
  }
  let segments = case route, language {
    Home, _ -> ""
    About, Swedish -> "om-oss/"
    About, English -> "about/"
    Join, Swedish -> "bli-medlem/"
    Join, English -> "join/"
    Booking, Swedish -> "boka-oss/"
    Booking, English -> "book-us/"
    Contact, Swedish -> "kontakt/"
    Contact, English -> "contact/"
    Concerts, Swedish -> "konserter/"
    Concerts, English -> "concerts/"
    Concert(slug), Swedish -> "konserter/" <> slug <> "/"
    Concert(slug), English -> "concerts/" <> slug <> "/"
    News, Swedish -> "nyheter/"
    News, English -> "news/"
    NewsItem(slug), Swedish -> "nyheter/" <> slug <> "/"
    NewsItem(slug), English -> "news/" <> slug <> "/"
  }

  prefix <> segments
}

/// A link to the route, for use in `href`. Includes the site's base path.
///
pub fn href(site: Site, route: Route, language: Language) -> String {
  site.base_path <> path(route, language)
}

/// The route's absolute URL, for canonical links, Open Graph, and the sitemap.
///
pub fn url(site: Site, route: Route, language: Language) -> String {
  site.url <> path(route, language)
}

/// A link to a file in `assets/`, given its path from the site root.
///
pub fn asset(site: Site, path: String) -> String {
  site.base_path <> path
}

/// Where the route's HTML is written, relative to the output folder.
///
pub fn file(route: Route, language: Language) -> String {
  string.drop_start(path(route, language), 1) <> "index.html"
}
