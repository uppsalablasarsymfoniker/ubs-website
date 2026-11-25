import gleam/option.{None}
import gleam/string
import gleam/time/calendar
import lustre/element
import ubs_website/data/entry
import ubs_website/data/language.{English}
import ubs_website/data/news.{NewsItem}
import ubs_website/site
import ubs_website/view/news as news_view

fn untranslated_item() -> news.NewsItem {
  NewsItem(
    slug: "nyhet",
    date: calendar.Date(2026, calendar.November, 1),
    image: None,
    swedish: entry.Text(title: "Rubrik", summary: None, body: "<p>Text</p>"),
    english: None,
  )
}

fn render() -> String {
  let site =
    site.new(
      url: "https://example.org",
      analytics_token: None,
      today: calendar.Date(2026, calendar.November, 26),
    )

  news_view.detail_view(site, English, untranslated_item())
  |> element.fragment
  |> element.to_string
}

pub fn fallback_marks_only_the_swedish_text_test() -> Nil {
  let html = render()

  assert string.contains(html, "<article>")
  assert string.contains(html, "lang=\"sv\">Rubrik</h1>")
  assert string.contains(html, "<div class=\"prose\" lang=\"sv\"><p>Text</p>")
}

pub fn fallback_is_labelled_in_english_test() -> Nil {
  let html = render()

  assert string.contains(html, "In Swedish")
  let assert Ok(#(before_title, _)) = string.split_once(html, "Rubrik")
  assert string.contains(before_title, "← All news")
}
