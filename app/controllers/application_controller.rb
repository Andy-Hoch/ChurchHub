class ApplicationController < ActionController::Base
  include Authentication
  include ChurchScoped

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # The static page for older browsers has inline styles, so it goes out without a content security policy.
  allow_browser versions: :modern, block: -> {
    request.content_security_policy = nil
    render file: Rails.root.join("public/406-unsupported-browser.html"), layout: false, status: :not_acceptable
  }

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
