class ChurchesController < ApplicationController
  def new
    @church = Church.new
  end

  def create
    @church = Church.new(church_params)

    if @church.save_with_owner(Current.user)
      session[:church_id] = @church.id
      redirect_to hub_path, notice: t(".notice")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def church_params
      params.expect(church: %i[ name website_url ])
    end
end
