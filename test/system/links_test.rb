require "application_system_test_case"

class LinksTest < ApplicationSystemTestCase
  test "adding a link shows it on the public hub page" do
    sign_in_as users(:one)
    assert_selector "h1", text: "Links"

    click_on "Link hinzufügen"
    assert_selector "h1", text: "Neuer Link"
    wait_for_turbo

    fill_in "Titel", with: "Spenden"
    fill_in "Adresse (URL)", with: "https://example.com/spenden"
    assert_field "Titel", with: "Spenden"
    click_on "Speichern"

    assert_text "Link hinzugefügt."
    assert_selector "h1", text: "Links"
    assert_text "Spenden"

    visit public_hub_path(churches(:one).slug)
    assert_selector "h1", text: "Gemeinde Eins"
    assert_text "Spenden"
    assert_text "Gottesdienst live"
    assert_no_text "Intern"
  end
end
