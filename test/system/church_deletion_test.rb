require "application_system_test_case"

class ChurchDeletionTest < ApplicationSystemTestCase
  test "owner deletes one of several churches by typing its name" do
    church = churches(:one)
    churches(:two).memberships.create!(user: users(:one))

    sign_in_as users(:one)
    assert_selector "h1", text: "Links"

    select "Gemeinde Eins", from: "Kirche wechseln"
    assert_selector "#header", text: "Gemeinde Eins"
    wait_for_turbo

    click_on "Einstellungen"
    assert_current_path edit_church_path
    assert_selector "h1", text: "Kirche"
    wait_for_turbo

    fill_in "Zum Bestätigen „Gemeinde Eins“ eintippen", with: "Gemeinde Eins"
    assert_field "Zum Bestätigen „Gemeinde Eins“ eintippen", with: "Gemeinde Eins"
    click_on "Kirche endgültig löschen"

    assert_current_path hub_path
    assert_text "Andere Kirche"
    assert_text "„Gemeinde Eins“ wurde gelöscht."
    assert_not Church.exists?(church.id)
  end
end
