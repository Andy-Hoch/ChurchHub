class ApplicationMailer < ActionMailer::Base
  default from: -> { ENV["MAILER_FROM_ADDRESS"].presence || Rails.application.credentials.dig(:smtp, :from) || "from@example.com" }
  layout "mailer"
end
