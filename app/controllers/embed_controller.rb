# Serves the launcher script that churches embed on their own websites.
# Inherits from ActionController::Base on purpose: no authentication, no
# browser version guard (visitors of church sites use all kinds of browsers)
# and no cross-origin JavaScript protection, which would block the script tag.
class EmbedController < ActionController::Base
  include EmbedOrigin

  skip_forgery_protection
  content_security_policy false

  # The script contains the widget, so a new version of it must not be
  # answered with 304 Not Modified.
  etag { helpers.embed_widget_asset.digest }

  def show
    expires_in 5.minutes, public: true
    response.headers["Vary"] = "Referer"
    @hub = Hub.enabled.includes(:church, links: { form: :questions }).find_by(public_token: params[:token])

    if @hub.nil?
      render js: "/* #{t(".not_found")} */"
    # Only the Referer counts here: the response is cached per Referer (Vary).
    elsif !embedding_allowed_for?(@hub.church, host_of(request.referer))
      render js: "/* #{t(".not_allowed")} */"
    elsif stale?(etag: [ @hub, @hub.church, @hub.availability_key ], last_modified: [ @hub.updated_at, @hub.church.updated_at ].max, public: true)
      @allowed_hosts = [ @hub.church.website_host, request.host ] if @hub.church.embed_restricted?
      render :show
    end
  end
end
