require "test_helper"

class FormSubmissionMailerTest < ActionMailer::TestCase
  test "notifies without revealing the answers" do
    mail = FormSubmissionMailer.received(form_submissions(:unread))

    assert_equal [ "pastor@example.com" ], mail.to
    assert_equal "Neue Einsendung: Gebetsanliegen", mail.subject
    assert_match "http://example.com/forms/#{forms(:prayer).id}/submissions/#{form_submissions(:unread).id}", mail.text_part.body.to_s
    assert_no_match "Für meine Familie", mail.body.encoded
  end
end
