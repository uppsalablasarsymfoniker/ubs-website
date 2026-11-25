import gleam/option.{None}
import gleam/time/calendar
import ubs_website/data/language.{English, Swedish}
import ubs_website/route
import ubs_website/site

fn site(url: String) -> site.Site {
  site.new(
    url:,
    analytics_token: None,
    today: calendar.Date(2026, calendar.November, 25),
  )
}

pub fn paths_per_language_test() {
  assert route.path(route.Home, Swedish) == "/"
  assert route.path(route.Home, English) == "/en/"
  assert route.path(route.About, Swedish) == "/om-oss/"
  assert route.path(route.Concert("x"), English) == "/en/concerts/x/"
  assert route.path(route.NewsItem("y"), Swedish) == "/nyheter/y/"
}

pub fn links_include_the_base_path_test() {
  let preview = site("https://uppsalablasarsymfoniker.github.io/ubs-website/")

  assert preview.base_path == "/ubs-website"
  assert route.href(preview, route.Concerts, Swedish)
    == "/ubs-website/konserter/"
  assert route.url(preview, route.Join, English)
    == "https://uppsalablasarsymfoniker.github.io/ubs-website/en/join/"
  assert route.asset(preview, "/images/ubs-logo.svg")
    == "/ubs-website/images/ubs-logo.svg"
}

pub fn domain_root_has_no_base_path_test() {
  let live = site("https://www.uppsalablasarsymfoniker.se")

  assert live.base_path == ""
  assert route.href(live, route.Home, Swedish) == "/"
}

pub fn output_files_test() {
  assert route.file(route.Home, Swedish) == "index.html"
  assert route.file(route.Booking, English) == "en/book-us/index.html"
}
