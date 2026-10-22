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

  test "adding a weekly link for the livestream" do
    sign_in_as users(:one)
    assert_selector "h1", text: "Links"

    click_on "Link hinzufügen"
    assert_selector "h1", text: "Neuer Link"
    wait_for_turbo

    fill_in "Titel", with: "Livestream"
    fill_in "Adresse (URL)", with: "https://example.com/livestream"
    assert_no_field "Von (Uhrzeit)"

    find("summary", text: "Button anzeigen").click
    assert_selector "summary .badge", text: "Immer"
    choose "Jede Woche"
    check "So"
    fill_in "Von (Uhrzeit)", with: "08:00"
    fill_in "Bis (Uhrzeit)", with: "12:00"

    # Closed, the accordion still tells what is set, before saving too.
    find("summary", text: "Button anzeigen").click
    assert_no_field "Von (Uhrzeit)"
    assert_selector "summary .badge", text: "Zeitgesteuert"
    assert_selector "summary", text: "Jede Woche So 08:00–12:00"
    click_on "Speichern"

    assert_text "Link hinzugefügt."
    assert_text "Jede Woche So 08:00–12:00"

    visit edit_hub_link_path(Link.find_by!(title: "Livestream"))
    assert_selector "summary .badge", text: "Zeitgesteuert"
    assert_selector "summary", text: "Jede Woche So 08:00–12:00"
    assert_no_field "Von (Uhrzeit)"
  end

  test "picking times from the rolls" do
    sign_in_as users(:one)
    assert_selector "h1", text: "Links"
    visit new_hub_link_path
    wait_for_turbo

    find("summary", text: "Button anzeigen").click
    choose "Jede Woche"
    find_field("Von (Uhrzeit)").click
    find("[role=listbox][aria-label=Stunde] [role=option]", text: "09").click
    find("[role=listbox][aria-label=Minute] [role=option]", text: "30").click

    assert_field "Von (Uhrzeit)", with: "09:30"
    assert_selector "summary", text: "Jede Woche 09:30"
  end

  test "showing a link from a date picked in the calendar" do
    sign_in_as users(:one)
    assert_selector "h1", text: "Links"
    visit new_hub_link_path
    wait_for_turbo

    fill_in "Titel", with: "Adventskalender"
    fill_in "Adresse (URL)", with: "https://example.com/advent"
    find("summary", text: "Button anzeigen").click
    choose "Zeitraum"

    today = Date.current
    find_field("Ab").click
    within ".date-picker" do
      find("button[aria-label='#{I18n.l(today, format: "%A, %-d. %B %Y")}']").click
      click_on "Fertig"
    end

    shown = "#{I18n.l(today, format: "%d.%m.%Y")} 00:00"
    assert_field "Ab", with: shown
    assert_selector "summary", text: "ab #{shown}"
    click_on "Speichern"

    assert_text "Link hinzugefügt."
    assert_equal today.beginning_of_day, Link.find_by!(title: "Adventskalender").visible_from
  end
end
