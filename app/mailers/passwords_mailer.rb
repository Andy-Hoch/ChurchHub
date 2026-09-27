class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "Passwort zurücksetzen", to: user.email_address
  end
end
