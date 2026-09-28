# Preview all emails at http://localhost:3000/rails/mailers/form_submission_mailer
class FormSubmissionMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/form_submission_mailer/received
  def received
    FormSubmissionMailer.received(FormSubmission.take)
  end
end
