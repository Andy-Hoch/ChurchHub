require "test_helper"

class PurgeInactiveSessionsJobTest < ActiveJob::TestCase
  test "deletes sessions that haven't been used for a while" do
    inactive = users(:one).sessions.create!(updated_at: 31.days.ago)
    active = users(:one).sessions.create!(updated_at: 29.days.ago)

    PurgeInactiveSessionsJob.perform_now

    assert_not Session.exists?(inactive.id)
    assert Session.exists?(active.id)
  end
end
