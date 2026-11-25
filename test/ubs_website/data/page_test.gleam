import simplifile
import ubs_website/data/page
import ubs_website/error

pub fn page_without_english_fails_test() -> Nil {
  let directory = "build/test-content/pages"
  let _ = simplifile.delete(directory)
  let assert Ok(_) = simplifile.create_directory_all(directory)
  let assert Ok(_) =
    simplifile.write(directory <> "/home.sv.md", "+++\ntitle = \"Hem\"\n+++\n")

  assert page.load(directory)
    == Error(error.ContentMissingTranslation(directory <> "/home.en.md"))
}
