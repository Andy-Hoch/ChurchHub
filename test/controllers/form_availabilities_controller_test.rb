require "test_helper"

class FormAvailabilitiesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "shows the availability settings" do
    get edit_form_availability_path(forms(:prayer))

    assert_response :success
    assert_match "Höchstzahl an Einsendungen", response.body
  end

  test "updates availability settings" do
    patch form_availability_path(forms(:prayer)), params: { form: { opens_at: "2026-11-01T08:00", closes_at: "2026-11-08T08:00", submission_limit: "20", when_full: "notice", full_message: "Ausgebucht" } }

    assert_redirected_to edit_form_availability_path(forms(:prayer))
    form = forms(:prayer).reload
    assert_equal Time.zone.parse("2026-11-01 08:00"), form.opens_at
    assert_equal 20, form.submission_limit
    assert form.when_full_notice?
    assert_equal "Ausgebucht", form.full_message
  end

  test "rejects a window that closes before it opens" do
    patch form_availability_path(forms(:prayer)), params: { form: { opens_at: "2026-11-08T08:00", closes_at: "2026-11-01T08:00" } }

    assert_response :unprocessable_entity
    assert_nil forms(:prayer).reload.opens_at
  end

  test "cannot touch the availability of another church's form" do
    patch form_availability_path(forms(:other)), params: { form: { submission_limit: "1" } }

    assert_response :not_found
    assert_nil forms(:other).reload.submission_limit
  end
end
