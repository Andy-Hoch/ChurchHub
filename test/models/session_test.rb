require "test_helper"

class SessionTest < ActiveSupport::TestCase
  setup { @session = users(:one).sessions.create! }

  test "sessions unused for the inactivity limit are inactive" do
    assert_includes Session.active, @session

    @session.update_column(:updated_at, (Session::INACTIVITY_LIMIT + 1.minute).ago)
    assert_includes Session.inactive, @session
    assert_not_includes Session.active, @session
  end

  test "resume records use at most once an hour" do
    @session.update_column(:updated_at, 2.hours.ago)
    assert_changes -> { @session.reload.updated_at } do
      @session.resume
    end

    assert_no_changes -> { @session.reload.updated_at } do
      @session.resume
    end
  end
end
