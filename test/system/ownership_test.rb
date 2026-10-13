require "application_system_test_case"

class OwnershipTest < ApplicationSystemTestCase
  test "owner hands the church over to another member" do
    churches(:one).memberships.create!(user: users(:two))

    sign_in_as users(:one)
    assert_selector "h1", text: "Links"
    click_on "Einstellungen"
    assert_selector "h1", text: "Kirche"
    wait_for_turbo

    accept_confirm { click_on "Zum Besitzer machen" }
    assert_text "Ben Beispiel ist jetzt Besitzer."
    wait_for_turbo

    accept_confirm { click_on "Zum Admin machen", match: :first }
    assert_text "Anna Beispiel ist jetzt Admin."
    assert_no_button "Speichern"
    assert churches(:one).memberships.find_by!(user: users(:two)).owner?
  end
end
