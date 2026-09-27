require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires name and a password of at least 8 characters" do
    user = User.new(email_address: "neu@example.com", password: "kurz")

    assert_not user.valid?
    assert_includes user.errors.attribute_names, :name
    assert_includes user.errors.attribute_names, :password
  end

  test "closing the account deletes churches without other members" do
    church = churches(:one)

    assert_difference [ "User.count", "Church.count", "Hub.count" ], -1 do
      users(:one).close_account!
    end

    assert_not Church.exists?(church.id)
    assert Church.exists?(churches(:two).id)
  end

  test "closing the account hands ownership to the longest-standing member" do
    church = churches(:one)
    clara = User.create!(name: "Clara", email_address: "clara@example.com", password: "geheim123")
    church.memberships.create!(user: users(:two), role: :admin, created_at: 2.days.ago)
    church.memberships.create!(user: clara, role: :admin, created_at: 1.day.ago)

    assert_equal users(:two), users(:one).owner_after_closing_account(church)
    users(:one).close_account!

    assert church.memberships.find_by!(user: users(:two)).owner?
    assert church.memberships.find_by!(user: clara).admin?
  end

  test "closing the account keeps other owners as they are" do
    church = churches(:one)
    church.memberships.create!(user: users(:two), role: :owner)
    memberships(:one).update!(role: :admin)

    users(:one).close_account!

    assert_equal [ users(:two) ], church.reload.users.to_a
    assert church.memberships.sole.owner?
  end
end
