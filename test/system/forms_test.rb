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

  test "visitors answer one question after another inside the launcher and admins see the submission" do
    hubs(:one).links.create!(title: "Gebet", kind: "form", form: forms(:prayer))
    open_launcher_form "Gebet"

    assert_operator @launcher.find(".panel.panel--form").rect.width, :<=, 360
    @launcher.assert_no_selector ".list"
    assert_current_step ".intro", text: "Wir beten gerne für dich."
    @launcher.assert_no_selector ".btn-secondary"
    @launcher.find(".btn-primary", text: "Los geht’s").click

    assert_current_step ".step-count", text: "Frage 1 von 4"
    next_step
    assert_current_step ".error", text: "Bitte beantworte diese Frage."
    current_step.find("textarea").set("Für unsere Gemeinde")
    next_step

    assert_current_step ".step-count", text: "Frage 2 von 4"
    current_step.find("input.input").set("Anna")
    next_step

    current_step.find(".option", text: "Nur das Gebetsteam").click
    next_step
    assert_current_step ".question", text: "Deine E-Mail-Adresse"

    @launcher.find(".btn-secondary[aria-label='Zurück']").click
    assert_current_step ".option:has(:checked)", text: "Nur das Gebetsteam"
    next_step
    next_step

    assert_current_step ".question", text: "Stimmt alles so?"
    assert_current_step ".review-value", text: "Für unsere Gemeinde"
    assert_current_step ".review-value--empty", text: "Keine Angabe"
    @launcher.assert_no_selector ".btn-primary", text: "Absenden"
    next_step

    assert_current_step ".question", text: "Datenschutz"
    @launcher.find(".btn-primary", text: "Absenden").click
    assert_current_step ".error", text: "Bitte stimme der Datenverarbeitung zu."
    current_step.find(".consent input").click
    @launcher.find(".btn-primary", text: "Absenden").click

    @launcher.assert_selector ".done .question", text: "Vielen Dank!"
    @launcher.find(".btn-primary", text: "Schließen").click
    @launcher.assert_selector "button.link:focus", text: "Gebet"

    sign_in_as users(:one)
    assert_selector "h1", text: "Links"
    visit form_submissions_path(forms(:prayer))
    click_on "Für unsere Gemeinde"

    assert_text "Anna"
    assert_text "Nur das Gebetsteam"
  end

  test "visitors can swipe past questions, but sending takes them back to the missing answers" do
    hubs(:one).links.create!(title: "Gebet", kind: "form", form: forms(:prayer))
    open_launcher_form "Gebet"

    swipe_to 5
    assert_current_step ".question", text: "Stimmt alles so?"
    assert_current_step ".review .error", text: "Bitte beantworte diese Frage.", count: 2

    swipe_to 6
    current_step.find(".consent input").click
    @launcher.find(".btn-primary", text: "Absenden").click

    assert_current_step ".step-count", text: "Frage 1 von 4"
    assert_current_step ".error", text: "Bitte beantworte diese Frage."
    current_step.find("textarea").set("Für unsere Gemeinde")
    @launcher.find(".btn-primary", text: "Zur Übersicht").click

    assert_current_step ".question", text: "Stimmt alles so?"
    assert_current_step ".review .error", count: 1
    next_step
    @launcher.find(".btn-primary", text: "Absenden").click

    assert_current_step ".step-count", text: "Frage 3 von 4"
    current_step.find(".option", text: "Die ganze Gemeinde").click
    @launcher.find(".btn-primary", text: "Zur Übersicht").click
    next_step

    assert_difference -> { forms(:prayer).submissions.count } do
      @launcher.find(".btn-primary", text: "Absenden").click
      @launcher.assert_selector ".done .question", text: "Vielen Dank!"
    end
  end

  test "visitors see the church's privacy link before sending even without a consent text" do
    churches(:one).update!(consent_text: nil, privacy_url: "https://example.com/datenschutz")
    form = churches(:one).forms.create!(title: "Feedback")
    form.questions.create!(label: "Was möchtest du uns sagen?", kind: "short_text", required: true)
    hubs(:one).links.create!(title: "Feedback", kind: "form", form: form)

    open_launcher_form "Feedback"
    current_step.find("input.input").set("Danke!")
    next_step

    assert_current_step ".question", text: "Stimmt alles so?"
    @launcher.assert_no_selector ".btn-primary", text: "Absenden"
    next_step

    assert_current_step ".question", text: "Datenschutz"
    @launcher.assert_no_selector ".consent"
    assert_current_step ".privacy a[href='https://example.com/datenschutz']", text: "Datenschutzerklärung"
    @launcher.find(".btn-primary", text: "Absenden").click

    @launcher.assert_selector ".done .question", text: "Vielen Dank!"
    assert_equal 1, form.submissions.count
  end

  test "forms are sent right from the review when the church has no consent text or privacy link" do
    churches(:one).update!(consent_text: nil)
    form = churches(:one).forms.create!(title: "Feedback")
    form.questions.create!(label: "Was möchtest du uns sagen?", kind: "short_text", required: true)
    hubs(:one).links.create!(title: "Feedback", kind: "form", form: form)

    open_launcher_form "Feedback"
    current_step.find("input.input").set("Danke!")
    next_step

    assert_current_step ".question", text: "Stimmt alles so?"
    @launcher.find(".btn-primary", text: "Absenden").click

    @launcher.assert_selector ".done .question", text: "Vielen Dank!"
    assert_equal 1, form.submissions.count
  end

  test "visitors submit forms on the public hub page, even when the launcher is limited to the church website" do
    churches(:one).update!(website_url: "https://kirche.example")
    hubs(:one).links.create!(title: "Gebet", kind: "form", form: forms(:prayer))

    visit public_hub_path(churches(:one).slug)
    click_on "Gebet"

    @launcher = find("[data-kirchen-hub]", visible: :all).shadow_root
    @launcher.assert_no_selector ".launcher .button"
    assert_operator @launcher.find(".backdrop .panel--form").rect.width, :<=, 360
    assert_current_step ".intro", text: "Wir beten gerne für dich."
    @launcher.find(".btn-primary", text: "Los geht’s").click
    current_step.find("textarea").set("Für die Jugendfreizeit")
    next_step
    next_step
    current_step.find(".option", text: "Nur das Gebetsteam").click
    next_step
    next_step
    next_step
    current_step.find(".consent input").click

    assert_difference -> { forms(:prayer).submissions.count } do
      @launcher.find(".btn-primary", text: "Absenden").click
      @launcher.assert_selector ".done .question", text: "Vielen Dank!"
    end

    @launcher.find(".btn-primary", text: "Schließen").click
    @launcher.assert_no_selector ".backdrop"
    assert_selector "button.link:focus", text: "Gebet"
  end

  private
    def open_launcher_form(title)
      visit "/embed-demo.html?token=#{hubs(:one).public_token}"
      @launcher = find("[data-kirchen-hub]", visible: :all).shadow_root
      @launcher.find(".button").click
      @launcher.find("button.link", text: title).click
    end

    def current_step
      @launcher.find(".slide[aria-current=step]")
    end

    def assert_current_step(selector, **options)
      current_step.assert_selector(selector, **options)
    end

    def next_step
      @launcher.find(".btn-primary", text: "Weiter").click
    end

    # Scrolls the slides like a swipe would.
    def swipe_to(index)
      execute_script(<<~JS, index)
        var slides = document.querySelector("[data-kirchen-hub]").shadowRoot.querySelector(".slides");
        slides.scrollLeft = arguments[0] * slides.clientWidth;
      JS
    end
end
