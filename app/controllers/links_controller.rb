class LinksController < ApplicationController
  before_action :require_church
  before_action :set_hub
  before_action :set_link, only: %i[ edit update destroy position ]

  def new
    @link = @hub.links.new
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

    def link_params
      params.expect(link: %i[ title url description icon visible ])
    end
end
