// IMPORTS ---------------------------------------------------------------------

import gleam/string
import simplifile
import tom

// TYPES -----------------------------------------------------------------------

/// Everything the build can fail on. Content variants carry the file path so
/// an editor can find the problem from the CI log alone.
///
pub type Error {
  ContentCouldNotBeListed(directory: String, reason: simplifile.FileError)
  ContentCouldNotBeRead(path: String, reason: simplifile.FileError)
  ContentMissingFrontMatter(path: String)
  ContentInvalidFrontMatter(path: String, reason: tom.ParseError)
  ContentInvalidToml(path: String, reason: tom.ParseError)
  ContentUnexpectedFile(path: String)
  ContentMissingField(path: String, field: String)
  ContentInvalidField(path: String, field: String, expected: String)
  ContentMissingTranslation(path: String)
  ContentMissingSwedish(path: String)
  ContentUnknownSection(path: String, section: String)
  OutputCouldNotBeWritten(path: String, reason: simplifile.FileError)
  AssetsCouldNotBeCopied(reason: simplifile.FileError)
  StylesCouldNotBeBuilt(reason: String)
}

// CONVERSIONS -----------------------------------------------------------------

pub fn to_string(error: Error) -> String {
  case error {
    ContentCouldNotBeListed(directory:, reason:) ->
      "Could not list "
      <> directory
      <> ": "
      <> simplifile.describe_error(reason)
    ContentCouldNotBeRead(path:, reason:) ->
      "Could not read " <> path <> ": " <> simplifile.describe_error(reason)
    ContentMissingFrontMatter(path:) ->
      path <> " must start with front matter between two `+++` lines."
    ContentInvalidFrontMatter(path:, reason:) ->
      path <> " has invalid front matter: " <> parse_error_to_string(reason)
    ContentInvalidToml(path:, reason:) ->
      path <> " is not valid TOML: " <> parse_error_to_string(reason)
    ContentUnexpectedFile(path:) ->
      path
      <> " is not named <name>.sv.md or <name>.en.md, so it would not appear on the site."
    ContentMissingField(path:, field:) ->
      path <> " is missing the required field `" <> field <> "`."
    ContentInvalidField(path:, field:, expected:) ->
      path <> ": the field `" <> field <> "` should be " <> expected <> "."
    ContentMissingTranslation(path:) ->
      "The English translation "
      <> path
      <> " is missing. General pages need both languages."
    ContentMissingSwedish(path:) ->
      path
      <> " has no Swedish version. Swedish is required; English is optional."
    ContentUnknownSection(path:, section:) ->
      path <> ": unknown section `" <> section <> "`."
    OutputCouldNotBeWritten(path:, reason:) ->
      "Could not write " <> path <> ": " <> simplifile.describe_error(reason)
    AssetsCouldNotBeCopied(reason:) ->
      "Could not copy assets: " <> simplifile.describe_error(reason)
    StylesCouldNotBeBuilt(reason:) -> "Tailwind failed: " <> reason
  }
}

fn parse_error_to_string(error: tom.ParseError) -> String {
  case error {
    tom.Unexpected(got:, expected:) ->
      "expected " <> expected <> " but found " <> string.inspect(got)
    tom.KeyAlreadyInUse(key:) ->
      "the key `" <> string.join(key, ".") <> "` appears more than once"
  }
}
