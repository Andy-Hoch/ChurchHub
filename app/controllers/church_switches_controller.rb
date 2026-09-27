class ChurchSwitchesController < ApplicationController
  def update
    church = Current.user.churches.find(params[:church_id])
    session[:church_id] = church.id
    redirect_to hub_path
  end
end
