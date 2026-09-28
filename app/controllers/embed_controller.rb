# Serves the launcher script that churches embed on their own websites.
# Inherits from ActionController::Base on purpose: no authentication, no
# browser version guard (visitors of church sites use all kinds of browsers)
# and no cross-origin JavaScript protection, which would block the script tag.
class EmbedController < ActionController::Base
  skip_forgery_protection

  def show
    expires_in 5.minutes, public: true
    @hub = Hub.includes(links: { form: :questions }).find_by(public_token: params[:token], enabled: true)

    if @hub.nil?
      render js: "/* Hub nicht gefunden oder deaktiviert */"
    elsif stale?(@hub, public: true)
      render :show
    end
  end
end
