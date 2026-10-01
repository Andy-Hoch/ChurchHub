class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :churches, through: :memberships

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :name, presence: true
  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :confirms_christian_organization, acceptance: { message: "muss bestätigt werden" }

  # Deletes the user. Churches without other members are deleted with them;
  # in the others, the longest-standing member takes over if no owner is left.
  def close_account!
    transaction do
      memberships.includes(:church).each do |membership|
        others = other_memberships_in(membership.church)

        if others.none?
          membership.church.destroy!
        elsif membership.owner? && !others.owner.exists?
          others.first.owner!
        end
      end

      destroy!
    end
  end

  # Who owns the church after this user closes their account, or nil if the
  # church is deleted with the account.
  def owner_after_closing_account(church)
    others = other_memberships_in(church)
    (others.owner.first || others.first)&.user
  end

  private
    def other_memberships_in(church)
      church.memberships.where.not(user_id: id).order(:created_at, :id)
    end
end
