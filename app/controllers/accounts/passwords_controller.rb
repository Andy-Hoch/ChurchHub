class Accounts::PasswordsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :update, with: -> { redirect_to edit_account_path, alert: t("rate_limited"), status: :see_other }

  def update
    if !Current.user.authenticate(params[:current_password].to_s)
      redirect_to edit_account_path, alert: t(".wrong_password"), status: :see_other
    # has_secure_password silently ignores a blank password, which would
    # report success without changing anything.
    elsif params[:password].present? && Current.user.update(params.permit(:password, :password_confirmation))
      Current.user.sessions.where.not(id: Current.session.id).destroy_all
      redirect_to edit_account_path, notice: t(".notice"), status: :see_other
    else
      redirect_to edit_account_path, alert: t(".invalid"), status: :see_other
    end
  end
end
