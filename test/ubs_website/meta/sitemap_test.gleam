import gleam/option.{None}
import gleam/string
import gleam/time/calendar
import ubs_website/meta/sitemap
import ubs_website/route
import ubs_website/site

pub fn sitemap_lists_both_languages_test() {
  let site =
    site.new(
      url: "https://example.org/ubs-website",
      analytics_token: None,
      today: calendar.Date(2026, calendar.November, 25),
    )
  let xml = sitemap.from_routes(site, [route.About])

  assert string.contains(
    xml,
    "<loc>https://example.org/ubs-website/om-oss/</loc>",
  )
  assert string.contains(
    xml,
    "<loc>https://example.org/ubs-website/en/about/</loc>",
  )
  assert string.contains(
    xml,
    "hreflang=\"en\" href=\"https://example.org/ubs-website/en/about/\"",
  )
}
