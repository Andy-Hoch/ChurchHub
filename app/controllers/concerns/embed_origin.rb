# Origin checks for the public embed endpoints. When a church limits its
# launcher to its website, requests must come from there or from this app
# itself (the public hub page). Browsers send at least the embedding page's
# origin by default; requests that reveal no host (e.g. with
# referrerpolicy="no-referrer") are let through, because the launcher script
# checks the page's host itself before mounting.
module EmbedOrigin
  extend ActiveSupport::Concern

  private
    def embedding_allowed_for?(church, host)
      host.nil? || host == request.host || church.embed_allowed_host?(host)
    end

    def host_of(url)
      URI.parse(url).host.presence if url.present?
    rescue URI::InvalidURIError
      nil
    end
end
