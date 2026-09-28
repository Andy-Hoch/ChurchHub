require "test_helper"

class FormQuestionsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "adds a choice question" do
    assert_difference -> { forms(:prayer).questions.count } do
      post form_questions_path(forms(:prayer)), params: { form_question: { label: "Wie oft?", kind: "single_choice", choices_text: "Einmal\nImmer", required: "1" } }
    end

    assert_redirected_to form_path(forms(:prayer))
    question = forms(:prayer).questions.last
    assert_equal %w[ Einmal Immer ], question.choices
    assert question.required?
  end

  test "rejects a choice question without choices" do
    post form_questions_path(forms(:prayer)), params: { form_question: { label: "Wie oft?", kind: "multiple_choice", choices_text: "" } }

    assert_response :unprocessable_entity
  end

  test "updates and deletes a question" do
    patch form_question_path(forms(:prayer), form_questions(:name)), params: { form_question: { label: "Dein Vorname?" } }
    assert_equal "Dein Vorname?", form_questions(:name).reload.label

    assert_difference -> { forms(:prayer).questions.count }, -1 do
      delete form_question_path(forms(:prayer), form_questions(:name))
    end
  end

  test "reorders questions" do
    put position_form_question_path(forms(:prayer), form_questions(:email)), params: { position: 0 }

    assert_response :no_content
    assert_equal "Deine E-Mail-Adresse", forms(:prayer).questions.reload.first.label
  end

  test "cannot touch questions of another church" do
    patch form_question_path(forms(:other), form_questions(:other)), params: { form_question: { label: "Gehackt" } }
    assert_response :not_found

    patch form_question_path(forms(:prayer), form_questions(:other)), params: { form_question: { label: "Gehackt" } }
    assert_response :not_found
    assert_equal "Frage der anderen Kirche", form_questions(:other).reload.label
  end
end
