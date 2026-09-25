require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  test "a user can only join a church once" do
    duplicate = Membership.new(user: users(:one), church: churches(:one))

    assert_not duplicate.valid?
  end
end
