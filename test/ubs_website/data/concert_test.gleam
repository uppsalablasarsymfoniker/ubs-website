import gleam/list
import gleam/option.{None}
import gleam/time/calendar
import ubs_website/data/concert.{type Concert, Concert, Performance}
import ubs_website/data/entry

fn concert(slug: String, days: List(Int)) -> Concert {
  let performances =
    list.map(days, fn(day) {
      Performance(
        calendar.Date(2026, calendar.November, day),
        calendar.TimeOfDay(19, 0, 0, 0),
      )
    })
  Concert(
    slug:,
    performances:,
    venue: "UKK",
    ticket_url: None,
    image: None,
    swedish: entry.Text(title: slug, summary: None, body: ""),
    english: None,
  )
}

const today = calendar.Date(2026, calendar.November, 25)

pub fn concert_is_upcoming_through_its_last_day_test() {
  assert concert.status(concert("today", [25]), today) == concert.Upcoming
  assert concert.status(concert("run", [24, 26]), today) == concert.Upcoming
  assert concert.status(concert("yesterday", [24]), today) == concert.Past
}

pub fn upcoming_soonest_first_and_past_newest_first_test() {
  let concerts = [
    concert("c", [28]),
    concert("a", [1]),
    concert("d", [26]),
    concert("b", [10]),
  ]

  assert concert.upcoming(concerts, today) |> list.map(fn(c) { c.slug })
    == ["d", "c"]
  assert concert.past(concerts, today) |> list.map(fn(c) { c.slug })
    == ["b", "a"]
}
