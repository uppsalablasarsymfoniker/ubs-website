// IMPORTS ---------------------------------------------------------------------

import filepath
import gleam/list
import gleam/result
import lustre/element.{type Element}
import simplifile
import ubs_website/data/content.{type Content}
import ubs_website/data/language.{type Language}
import ubs_website/data/site.{type Site}
import ubs_website/error.{type Error}
import ubs_website/route.{type Route}
import ubs_website/tailwind
import ubs_website/view/concert as concert_view
import ubs_website/view/document
import ubs_website/view/page

// MAIN ------------------------------------------------------------------------

/// Read `content/`, render every page in both languages into `dist/`, copy
/// `assets/`, and compile the stylesheet.
///
pub fn main() -> Result(Nil, Error) {
  let site = site.from_environment()
  use content <- result.try(content.load("content"))
  run(site, content, "dist")
}

pub fn run(site: Site, content: Content, out: String) -> Result(Nil, Error) {
  let _ = simplifile.delete(out)
  use _ <- result.try(
    simplifile.copy_directory("assets", out)
    |> result.map_error(error.AssetsCouldNotBeCopied),
  )
  use _ <- result.try(
    list.try_each(pages(site, content), fn(page) {
      let #(route, language, html) = page
      write(filepath.join(out, route.file(route, language)), html)
    }),
  )

  tailwind.run(input: "src/app.css", output: filepath.join(out, "css/site.css"))
}

fn write(path: String, html: Element(a)) -> Result(Nil, Error) {
  let html = element.to_document_string(html)
  simplifile.create_directory_all(filepath.directory_name(path))
  |> result.try(fn(_) { simplifile.write(path, html) })
  |> result.map_error(error.OutputCouldNotBeWritten(path, _))
}

// PAGES -----------------------------------------------------------------------

fn pages(
  site: Site,
  content: Content,
) -> List(#(Route, Language, Element(Nil))) {
  use language <- list.flat_map(language.all)
  let pages = content.pages
  let settings = content.settings
  let render = fn(meta: document.Meta, body) {
    #(meta.route, language, document.view(site, settings, language, meta, body))
  }
  let general = fn(route, text, after) {
    let text = language.get(text, language)
    render(page.meta(text, route), page.view(text, after))
  }

  [
    general(route.Home, pages.home, []),
    general(route.About, pages.about, []),
    general(route.Join, pages.join, [page.email_button(settings, language)]),
    general(route.Booking, pages.booking, [
      page.email_button(settings, language),
    ]),
    general(route.Contact, pages.contact, [
      page.contact_details(settings, language),
    ]),
    render(
      concert_view.list_meta(language),
      concert_view.list_view(site, language, content.concerts),
    ),
    ..list.map(content.concerts, fn(concert) {
      render(
        concert_view.detail_meta(language, concert),
        concert_view.detail_view(site, language, concert),
      )
    })
  ]
}
