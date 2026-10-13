class Session < ApplicationRecord
  # Sessions that haven't been used for this long end and get deleted
  # (PurgeInactiveSessionsJob), together with their IP address and browser.
  INACTIVITY_LIMIT = 30.days

  belongs_to :user

  scope :active, -> { where(updated_at: INACTIVITY_LIMIT.ago..) }
  scope :inactive, -> { where(updated_at: ...INACTIVITY_LIMIT.ago) }

  # Records that the session is in use, at most once an hour to keep writes rare.
  def resume
    touch if updated_at.before?(1.hour.ago)
    self
  end
end
