# Serves the launcher script that churches embed on their own websites.
# Inherits from ActionController::Base on purpose: no authentication, no
# browser version guard (visitors of church sites use all kinds of browsers)
# and no cross-origin JavaScript protection, which would block the script tag.
class EmbedController < ActionController::Base
  skip_forgery_protection

  def show
    expires_in 5.minutes, public: true
    response.headers["Vary"] = "Referer"
    @hub = Hub.includes(:church, :links).find_by(public_token: params[:token], enabled: true)

    if @hub.nil?
      render js: "/* Hub nicht gefunden oder deaktiviert */"
    elsif !embedding_allowed?
      render js: "/* Launcher ist für diese Webseite nicht freigegeben */"
    elsif stale?([ @hub, @hub.church ], public: true)
      @allowed_hosts = [ @hub.church.website_host, request.host ] if @hub.church.embed_restricted?
      render :show
    end
  end

  private
    # Browsers send at least the embedding page's origin as Referer by default.
    # Without one (e.g. referrerpolicy="no-referrer") the script itself checks
    # the page's host before mounting.
    def embedding_allowed?
      host = referer_host
      host.nil? || host == request.host || @hub.church.embed_allowed_host?(host)
    end

    def referer_host
      URI.parse(request.referer).host.presence if request.referer.present?
    rescue URI::InvalidURIError
      nil
    end
end
