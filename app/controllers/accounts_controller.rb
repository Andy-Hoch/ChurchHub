class AccountsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :destroy, with: -> { redirect_to edit_account_path, alert: t("rate_limited"), status: :see_other }

  def edit
    @churches = Current.user.churches.order(:name)
  end

  def destroy
    if Current.user.authenticate(params[:password].to_s)
      Current.user.close_account!
      cookies.delete(:session_id)
      reset_session
      redirect_to new_session_path, notice: t(".notice"), status: :see_other
    else
      redirect_to edit_account_path, alert: t(".wrong_password"), status: :see_other
    end
  end
end
