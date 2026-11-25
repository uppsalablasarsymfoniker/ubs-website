import gleam/list
import gleam/option.{Some}
import ubs_website/data/content
import ubs_website/error

pub fn repository_content_loads_test() {
  case content.load("content") {
    Ok(loaded) -> {
      assert loaded.concerts != []
      assert list.any(loaded.concerts, fn(concert) {
        case concert.english {
          Some(_) -> True
          option.None -> False
        }
      })
    }
    Error(problem) -> panic as error.to_string(problem)
  }
}
