# Shows a church's hub as a standalone page under /<kirchenname>, e.g. for
# sharing via QR code or social media. Public, like the embed script.
class PublicHubsController < ActionController::Base
  def show
    @hub = Hub.enabled.joins(:church).find_by!(churches: { slug: params[:slug] })

    # Forms open through the launcher script, loaded without its button.
    @links = @hub.links.includes(:form).select(&:embeddable?)
    fresh_when @hub, public: true
  end
end
