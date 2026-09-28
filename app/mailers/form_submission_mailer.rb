class FormSubmissionMailer < ApplicationMailer
  # Deliberately without the answers: they can be personal (prayer requests)
  # and should only be read after logging in.
  def received(submission)
    @submission = submission
    @form = submission.form
    mail to: @form.notification_email_list, subject: "Neue Einsendung: #{@form.title}"
  end
end
