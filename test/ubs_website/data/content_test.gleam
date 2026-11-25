import ubs_website/data/content
import ubs_website/error

/// The repository's own content must always build. Editors change it freely,
/// so this checks only that it loads, not what it contains.
///
pub fn repository_content_loads_test() -> Nil {
  case content.load("content") {
    Ok(_) -> Nil
    Error(problem) -> panic as error.to_string(problem)
  }
}
