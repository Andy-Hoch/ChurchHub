require "application_system_test_case"

class LinksTest < ApplicationSystemTestCase
  test "adding a link shows it on the public hub page" do
    sign_in_as users(:one)
    assert_selector "h1", text: "Links"

    click_on "Link hinzufügen"
    fill_in "Titel", with: "Spenden"
    fill_in "Adresse (URL)", with: "https://example.com/spenden"
    click_on "Speichern"

    assert_selector "h1", text: "Links"
    assert_text "Spenden"

    visit public_hub_path(churches(:one).slug)
    assert_selector "h1", text: "Gemeinde Eins"
    assert_text "Spenden"
    assert_text "Gottesdienst live"
    assert_no_text "Intern"
  end
end
