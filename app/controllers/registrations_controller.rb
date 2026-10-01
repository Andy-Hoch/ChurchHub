class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Bitte versuche es später noch einmal." }
  layout "auth"

  def new
    @user = User.new
    @church = Church.new
  end

  def create
    @user = User.new(user_params)
    @church = Church.new(church_params)

    if [ @user.valid?, @church.valid? ].all?
      ActiveRecord::Base.transaction do
        @user.save!
        @church.save!
        @church.memberships.create!(user: @user, role: :owner)
      end
      start_new_session_for @user
      redirect_to hub_path, notice: "Willkommen! Dein Hub ist bereit."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def user_params
      params.expect(user: %i[ name email_address password password_confirmation confirms_christian_organization ])
    end

    def church_params
      params.expect(church: %i[ name website_url ])
    end
end
