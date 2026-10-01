class HubsController < ApplicationController
  before_action :require_church
  before_action :set_hub

  def show
  end

  def edit
  end

  def update
    if @hub.update(hub_params)
      redirect_back_or_to edit_hub_path, notice: "Änderungen gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def embed
  end

  def regenerate_token
    @hub.regenerate_public_token
    redirect_to embed_hub_path, notice: "Neuer Einbettungs-Code erzeugt. Bitte das Snippet auf deiner Webseite austauschen."
  end

  private
    def set_hub
      @hub = current_church.hub
    end

    def hub_params
      params.expect(hub: %i[ title enabled primary_color text_color position button_label button_icon color_scheme corner_radius font_family ])
    end
end
