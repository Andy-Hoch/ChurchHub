class CurrentChurchController < ApplicationController
  before_action :require_church
  before_action :require_owner, only: %i[ update destroy ]

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

  def destroy
    church = current_church

    if Current.user.churches.one?
      redirect_to edit_church_path, alert: "Deine einzige Kirche kannst du nicht löschen. Lösche stattdessen dein Konto.", status: :see_other
    elsif params[:confirmation].to_s.strip != church.name
      redirect_to edit_church_path, alert: "Der eingegebene Name stimmt nicht mit dem Namen der Kirche überein.", status: :see_other
    else
      church.destroy!
      session.delete(:church_id)
      redirect_to hub_path, notice: "„#{church.name}“ wurde gelöscht.", status: :see_other
    end
  end

  private
    def church_params
      params.expect(church: %i[ name slug ])
    end
end
