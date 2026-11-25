// IMPORTS ---------------------------------------------------------------------

import gleam/list
import gleam/string
import ubs_website/data/language
import ubs_website/data/site.{type Site}
import ubs_website/route.{type Route}

// CONSTRUCTORS ----------------------------------------------------------------

/// A sitemap listing every route in every language, each with links to its
/// translations so search engines can pair them. Written as plain strings
/// rather than Lustre elements, which would put the entries in the XHTML
/// namespace.
///
pub fn from_routes(site: Site, routes: List(Route)) -> String {
  let urls =
    list.flat_map(routes, fn(route) {
      list.map(language.all, fn(language) {
        url(site, route, route.url(site, route, language))
      })
    })

  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
  <> "<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\" "
  <> "xmlns:xhtml=\"http://www.w3.org/1999/xhtml\">\n"
  <> string.concat(urls)
  <> "</urlset>\n"
}

/// Points crawlers at the sitemap.
///
pub fn robots(site: Site) -> String {
  "User-agent: *\nAllow: /\n\nSitemap: " <> site.url <> "/sitemap.xml\n"
}

// ELEMENTS --------------------------------------------------------------------

fn url(site: Site, route: Route, location: String) -> String {
  let alternates =
    list.map(language.all, fn(language) {
      "    <xhtml:link rel=\"alternate\" hreflang=\""
      <> language.code(language)
      <> "\" href=\""
      <> escape(route.url(site, route, language))
      <> "\"/>\n"
    })

  "  <url>\n    <loc>"
  <> escape(location)
  <> "</loc>\n"
  <> string.concat(alternates)
  <> "  </url>\n"
}

fn escape(text: String) -> String {
  text
  |> string.replace("&", "&amp;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
  |> string.replace("\"", "&quot;")
}
