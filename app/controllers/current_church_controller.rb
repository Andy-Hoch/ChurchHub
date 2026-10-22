class CurrentChurchController < ApplicationController
  before_action :require_church
  before_action :require_owner, only: %i[ update destroy ]

  def edit
    @church = current_church
  end

  def update
    @church = current_church

    if @church.update(church_params)
      redirect_to edit_church_path, notice: t(".notice")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    church = current_church

    if Current.user.churches.one?
      redirect_to edit_church_path, alert: t(".only_church"), status: :see_other
    elsif params[:confirmation].to_s.strip != church.name
      redirect_to edit_church_path, alert: t(".name_mismatch"), status: :see_other
    else
      church.destroy!
      session.delete(:church_id)
      redirect_to hub_path, notice: t(".notice", name: church.name), status: :see_other
    end
  end

  private
    def church_params
      params.expect(church: %i[ name website_url slug consent_text privacy_url ])
    end
end
