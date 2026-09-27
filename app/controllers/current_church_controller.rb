class CurrentChurchController < ApplicationController
  before_action :require_church
  before_action :require_owner, only: :update

  def edit
    @church = current_church
  end

  def update
    @church = current_church

    if @church.update(church_params)
      redirect_to edit_church_path, notice: "Kirche gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def church_params
      params.expect(church: %i[ name slug ])
    end
end
