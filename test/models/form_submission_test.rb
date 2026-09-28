require "test_helper"

class FormSubmissionTest < ActiveSupport::TestCase
  test "stores answers together with the question labels" do
    submission = FormSubmission.build_from(forms(:prayer), {
      form_questions(:request).id.to_s => "Für meine Familie",
      form_questions(:visibility).id.to_s => "Nur das Gebetsteam"
    })

    assert submission.save
    request = submission.answers.first
    assert_equal "Wofür dürfen wir beten?", request["label"]
    assert_equal "Für meine Familie", request["value"]
    assert_nil submission.answers.second["value"]
  end

  test "collects errors per question" do
    submission = FormSubmission.build_from(forms(:prayer), { form_questions(:email).id.to_s => "keine-adresse" })

    assert_not submission.valid?
    assert_equal [ form_questions(:request).id, form_questions(:visibility).id, form_questions(:email).id ].sort, submission.answer_errors.keys.sort
  end

  test "ignores answers to unknown questions" do
    submission = FormSubmission.build_from(forms(:prayer), { form_questions(:other).id.to_s => "Fremd" })

    assert_not_includes submission.answers.map { |answer| answer["question_id"] }, form_questions(:other).id
  end

  test "read state" do
    submission = form_submissions(:unread)
    assert_not submission.read?

    submission.mark_read!
    assert submission.read?

    submission.toggle_read!
    assert_not submission.reload.read?
  end

  test "formats values for display" do
    assert_equal "A, B", FormSubmission.format_value("kind" => "multiple_choice", "value" => %w[ A B ])
    assert_equal "24.12.2026", FormSubmission.format_value("kind" => "date", "value" => "2026-12-24")
    assert_nil FormSubmission.format_value("kind" => "short_text", "value" => nil)
  end
end
