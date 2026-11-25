// IMPORTS ---------------------------------------------------------------------

import filepath
import gleam/result
import ubs_website/data/concert.{type Concert}
import ubs_website/data/member.{type Member}
import ubs_website/data/news.{type NewsItem}
import ubs_website/data/page.{type Pages}
import ubs_website/data/settings.{type Settings}
import ubs_website/error.{type Error}

// TYPES -----------------------------------------------------------------------

/// Everything in the `content/` folder, read and checked.
///
pub type Content {
  Content(
    pages: Pages,
    concerts: List(Concert),
    news: List(NewsItem),
    members: List(Member),
    settings: Settings,
  )
}

// CONSTRUCTORS ----------------------------------------------------------------

pub fn load(root: String) -> Result(Content, Error) {
  use pages <- result.try(page.load(filepath.join(root, "pages")))
  use concerts <- result.try(concert.load(filepath.join(root, "concerts")))
  use news <- result.try(news.load(filepath.join(root, "news")))
  use members <- result.try(member.load(filepath.join(root, "members.toml")))
  use settings <- result.try(
    settings.load(filepath.join(root, "settings.toml")),
  )

  Ok(Content(pages:, concerts:, news:, members:, settings:))
}
