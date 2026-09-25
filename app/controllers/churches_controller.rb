class ChurchesController < ApplicationController
  def new
    @church = Church.new
  end

  def create
    @church = Church.new(church_params)

    if @church.save
      @church.memberships.create!(user: Current.user, role: :owner)
      session[:church_id] = @church.id
      redirect_to hub_path, notice: "Kirche angelegt."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def church_params
      params.expect(church: %i[ name ])
    end
end
