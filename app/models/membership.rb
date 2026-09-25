class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :church

  enum :role, { owner: "owner", admin: "admin" }, default: :admin, validate: true

  validates :user_id, uniqueness: { scope: :church_id }
end
