import gleam/time/calendar
import ubs_website/data/language.{English, Swedish}
import ubs_website/view/date

pub fn dates_per_language_test() {
  let day = calendar.Date(2027, calendar.January, 30)

  assert date.to_human_readable(day, Swedish) == "30 januari 2027"
  assert date.to_human_readable(day, English) == "30 January 2027"
  assert date.to_iso8601(day) == "2027-01-30"
}

pub fn times_per_language_test() {
  let time = calendar.TimeOfDay(9, 5, 0, 0)

  assert date.time_to_human_readable(time, Swedish) == "09.05"
  assert date.time_to_human_readable(time, English) == "09:05"
}
