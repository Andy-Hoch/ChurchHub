class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :church

  enum :role, { owner: "owner", admin: "admin" }, default: :admin, validate: true

  validates :user_id, uniqueness: { scope: :church_id }
  validate :church_keeps_an_owner, on: :update, if: -> { role_changed?(from: "owner") }

  private
    def church_keeps_an_owner
      errors.add(:role, :last_owner) unless church.memberships.owner.where.not(id: id).exists?
    end
end
