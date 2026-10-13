class MembershipsController < ApplicationController
  before_action :require_church
  before_action :require_owner

  def create
    user = User.find_by(email_address: params[:email_address].to_s.strip.downcase)

    if user.nil?
      redirect_to edit_church_path, alert: t(".unknown_account"), status: :see_other
    elsif current_church.memberships.exists?(user: user)
      redirect_to edit_church_path, alert: t(".already_member", name: user.name), status: :see_other
    else
      current_church.memberships.create!(user: user, role: :admin)
      redirect_to edit_church_path, notice: t(".notice", name: user.name), status: :see_other
    end
  end

  # Makes a member owner or admin. Handing the church over means making
  # someone else owner first and then oneself admin.
  def update
    membership = current_church.memberships.find(params[:id])

    if membership.update(role: params.expect(:role))
      redirect_to edit_church_path, notice: t(".#{membership.role}", name: membership.user.name), status: :see_other
    else
      redirect_to edit_church_path, alert: membership.errors.full_messages.to_sentence, status: :see_other
    end
  end

  def destroy
    membership = current_church.memberships.find(params[:id])

    if membership.user == Current.user
      redirect_to edit_church_path, alert: t(".self"), status: :see_other
    else
      membership.destroy
      redirect_to edit_church_path, notice: t(".notice"), status: :see_other
    end
  end
end
