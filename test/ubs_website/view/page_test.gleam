import ubs_website/view/page

pub fn account_name_from_profile_url_test() -> Nil {
  assert page.account_name("https://www.instagram.com/ubsymfoniker/", "@")
    == "@ubsymfoniker"
  assert page.account_name(
      "https://www.facebook.com/uppsalablasarsymfoniker",
      "",
    )
    == "uppsalablasarsymfoniker"
}

pub fn account_name_falls_back_to_url_test() -> Nil {
  let numeric = "https://www.facebook.com/profile.php?id=100064"
  let no_path = "https://www.facebook.com/"

  assert page.account_name(numeric, "") == numeric
  assert page.account_name(no_path, "") == no_path
}
