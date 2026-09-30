# Shows a church's hub as a standalone page under /<kirchenname>, e.g. for
# sharing via QR code or social media. Public, like the embed script.
class PublicHubsController < ActionController::Base
  def show
    church = Church.find_by!(slug: params[:slug])
    @hub = church.hub
    raise ActiveRecord::RecordNotFound unless @hub&.enabled?

    # Forms open through the launcher script, loaded without its button.
    @links = @hub.links.includes(:form).select(&:embeddable?)
    fresh_when @hub, public: true
  end
end
