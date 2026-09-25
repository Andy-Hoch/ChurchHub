class PagesController < ApplicationController
  allow_unauthenticated_access
  layout "auth"

  def home
    redirect_to hub_path if authenticated?
  end
end
