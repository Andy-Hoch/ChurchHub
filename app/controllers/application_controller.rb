class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_church, :current_membership

  private
    def current_church
      return unless Current.user

      @current_church ||= Current.user.churches.find_by(id: session[:church_id]) || Current.user.churches.order(:id).first
    end

    def current_membership
      @current_membership ||= current_church&.memberships&.find_by(user: Current.user)
    end

    def require_church
      redirect_to new_church_path, alert: "Lege zuerst eine Kirche an." unless current_church
    end

    def require_owner
      redirect_to edit_church_path, alert: "Nur Besitzer dürfen das." unless current_membership&.owner?
    end
end
