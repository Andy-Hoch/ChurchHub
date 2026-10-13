# The church an admin is working on. Users can belong to several churches and
# switch between them; the choice is kept in the session.
module ChurchScoped
  extend ActiveSupport::Concern

  included do
    helper_method :current_church, :current_membership
  end

  private
    def current_church
      return @current_church if defined?(@current_church)

      @current_church = find_current_church
    end

    def current_membership
      return @current_membership if defined?(@current_membership)

      @current_membership = current_church&.memberships&.find_by(user: Current.user)
    end

    def require_church
      redirect_to new_church_path, alert: t("church_scoped.church_required") unless current_church
    end

    def require_owner
      redirect_to edit_church_path, alert: t("church_scoped.owner_required") unless current_membership&.owner?
    end

    # Falls back to the user's first church when the chosen one is gone (deleted
    # or membership removed) and remembers the fallback for the next requests.
    def find_current_church
      return unless Current.user

      church = Current.user.churches.find_by(id: session[:church_id]) || Current.user.churches.order(:id).first
      session[:church_id] = church.id if church && session[:church_id] != church.id
      church
    end
end
