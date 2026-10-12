# Shows a church's hub as a standalone page under /<kirchenname>, e.g. for
# sharing via QR code or social media. Public, like the embed script.
class PublicHubsController < ActionController::Base
  # The page is publicly cacheable and works without a session, so it gets
  # no nonce. Its styles are inline; scripts stay limited to this app.
  content_security_policy do |policy|
    policy.style_src :self, :unsafe_inline
  end

  def show
    @hub = Hub.enabled.joins(:church).find_by!(churches: { slug: params[:slug] })

    # Forms open through the launcher script, loaded without its button.
    @links = @hub.links.includes(:form).select(&:embeddable?)
    fresh_when @hub, public: true
  end
end
