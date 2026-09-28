require "test_helper"

class FormsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "lists the church's forms" do
    get forms_path

    assert_response :success
    assert_match "Gebetsanliegen", response.body
    assert_no_match "Anderes Formular", response.body
  end

  test "creates a form from a template" do
    assert_difference -> { churches(:one).forms.count } do
      post forms_path, params: { template: "contact" }
    end

    form = churches(:one).forms.order(:id).last
    assert_redirected_to form_path(form)
    assert_equal "Kontakt", form.title
    assert form.questions.any?
  end

  test "creates an empty form" do
    post forms_path, params: { form: { title: "Anmeldung Sommerfest" } }

    assert_redirected_to form_path(churches(:one).forms.find_by!(title: "Anmeldung Sommerfest"))
  end

  test "rejects a form without title" do
    assert_no_difference "Form.count" do
      post forms_path, params: { form: { title: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "shows questions and settings" do
    get form_path(forms(:prayer))
    assert_response :success
    assert_match "Wofür dürfen wir beten?", response.body

    get edit_form_path(forms(:prayer))
    assert_response :success
  end

  test "updates settings" do
    patch form_path(forms(:prayer)), params: { form: { thank_you_message: "Amen!", retention_months: "6" } }

    assert_redirected_to form_path(forms(:prayer))
    assert_equal "Amen!", forms(:prayer).reload.thank_you_message
    assert_equal 6, forms(:prayer).retention_months
  end

  test "destroys a form with its submissions" do
    assert_difference -> { FormSubmission.count }, -2 do
      delete form_path(forms(:prayer))
    end
    assert_redirected_to forms_path
  end

  test "cannot touch forms of another church" do
    get form_path(forms(:other))
    assert_response :not_found

    patch form_path(forms(:other)), params: { form: { title: "Gehackt" } }
    assert_response :not_found
    assert_equal "Anderes Formular", forms(:other).reload.title
  end
end
