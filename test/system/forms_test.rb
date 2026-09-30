require "application_system_test_case"

class FormsTest < ApplicationSystemTestCase
  setup do
    @minimum_fill_time = EmbedSubmissionsController.minimum_fill_time
    EmbedSubmissionsController.minimum_fill_time = 0
  end

  teardown { EmbedSubmissionsController.minimum_fill_time = @minimum_fill_time }

  test "creating a form from a template and adding it as a hub button" do
    sign_in_as users(:one)
    assert_selector "h1", text: "Links"

    click_on "Formulare"
    click_on "Formular anlegen"
    find(".template-card", text: "Kontakt / Rückruf").click

    assert_text "Formular angelegt."
    assert_text "Wann passt ein Rückruf am besten?"

    click_on "Als Button hinzufügen"
    assert_selector "h1", text: "Neuer Link"
    wait_for_turbo
    assert_checked_field "Formular öffnen"
    assert_select "Formular", selected: "Kontakt"
    assert_no_field "Adresse (URL)"

    fill_in "Titel", with: "Schreib uns"
    click_on "Speichern"

    assert_text "Link hinzugefügt."
    assert_text "Schreib uns"
  end

  test "visitors answer one question after another and admins see the submission" do
    hubs(:one).links.create!(title: "Gebet", kind: "form", form: forms(:prayer))

    visit "/embed-demo.html?token=#{hubs(:one).public_token}"
    launcher = find("[data-kirchen-hub]", visible: :all).shadow_root
    launcher.find(".button").click
    launcher.find("button.link", text: "Gebet").click

    launcher.assert_selector ".intro", text: "Wir beten gerne für dich."
    launcher.find(".btn-primary", text: "Los geht’s").click

    launcher.assert_selector ".step-count", text: "Frage 1 von 4"
    launcher.find(".btn-primary", text: "Weiter").click
    launcher.assert_selector ".error", text: "Bitte beantworte diese Frage."
    launcher.find("textarea").set("Für unsere Gemeinde")
    launcher.find(".btn-primary", text: "Weiter").click

    launcher.assert_selector ".step-count", text: "Frage 2 von 4"
    launcher.find("input.input").set("Anna")
    launcher.find(".btn-primary", text: "Weiter").click

    launcher.find(".option", text: "Nur das Gebetsteam").click
    launcher.find(".btn-primary", text: "Weiter").click
    launcher.assert_selector ".question", text: "Deine E-Mail-Adresse"

    launcher.find(".btn-secondary", text: "Zurück").click
    launcher.assert_selector ".option:has(:checked)", text: "Nur das Gebetsteam"
    launcher.find(".btn-primary", text: "Weiter").click
    launcher.find(".btn-primary", text: "Weiter").click

    launcher.assert_selector ".question", text: "Stimmt alles so?"
    launcher.assert_selector ".review-value", text: "Für unsere Gemeinde"
    launcher.assert_selector ".review-value--empty", text: "Keine Angabe"
    launcher.find(".btn-primary", text: "Absenden").click
    launcher.assert_selector ".error", text: "Bitte stimme der Datenverarbeitung zu."
    launcher.find(".consent input").click
    launcher.find(".btn-primary", text: "Absenden").click

    launcher.assert_selector ".question", text: "Vielen Dank!"

    sign_in_as users(:one)
    assert_selector "h1", text: "Links"
    visit form_submissions_path(forms(:prayer))
    click_on "Für unsere Gemeinde"

    assert_text "Anna"
    assert_text "Nur das Gebetsteam"
  end

  test "visitors open forms on the public hub page" do
    hubs(:one).links.create!(title: "Gebet", kind: "form", form: forms(:prayer))

    visit public_hub_path(churches(:one).slug)
    click_on "Gebet"

    launcher = find("[data-kirchen-hub]", visible: :all).shadow_root
    launcher.assert_selector ".intro", text: "Wir beten gerne für dich."
    launcher.assert_no_selector ".launcher .button"
    launcher.find(".btn-primary", text: "Los geht’s").click
    launcher.assert_selector ".step-count", text: "Frage 1 von 4"
  end
end
