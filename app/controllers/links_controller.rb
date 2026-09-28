class LinksController < ApplicationController
  before_action :require_church
  before_action :set_hub
  before_action :set_link, only: %i[ edit update destroy position ]
  before_action :set_forms, only: %i[ new create edit update ]

  def new
    @link = @hub.links.new(kind: params[:kind].presence_in(Link.kinds.keys) || "link", form_id: @forms.find_by(id: params[:form_id])&.id)
  end

  def create
    @link = @hub.links.new(link_params)

    if @link.save
      redirect_to hub_path, notice: "Link hinzugefügt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @link.update(link_params)
      redirect_to hub_path, notice: "Link gespeichert."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @link.destroy
    redirect_to hub_path, notice: "Link gelöscht.", status: :see_other
  end

  def position
    @link.move_to(params[:position])
    head :no_content
  end

  private
    def set_hub
      @hub = current_church.hub
    end

    def set_link
      @link = @hub.links.find(params[:id])
    end

    def set_forms
      @forms = current_church.forms.order(:title)
    end

    def link_params
      params.expect(link: %i[ title kind url form_id description icon visible ])
    end
end
