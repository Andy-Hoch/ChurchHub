require "test_helper"

class MembershipsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "only accounts that exist can be added" do
    assert_no_difference "Membership.count" do
      post church_memberships_path, params: { email_address: "niemand@example.com" }
    end

    assert_redirected_to edit_church_path
    assert_match "Kein Konto", flash[:alert]
  end

  test "finds accounts regardless of case and spaces" do
    assert_difference -> { churches(:one).memberships.count } do
      post church_memberships_path, params: { email_address: " TWO@example.com " }
    end
  end

  test "does not add members twice" do
    churches(:one).memberships.create!(user: users(:two))

    assert_no_difference "Membership.count" do
      post church_memberships_path, params: { email_address: "two@example.com" }
    end
    assert_match "bereits Mitglied", flash[:alert]
  end

  test "owners cannot remove themselves" do
    assert_no_difference "Membership.count" do
      delete church_membership_path(memberships(:one))
    end
    assert_match "nicht selbst entfernen", flash[:alert]
  end

  test "admins cannot manage members" do
    memberships(:one).update!(role: :admin)
    other = churches(:one).memberships.create!(user: users(:two))

    assert_no_difference "Membership.count" do
      post church_memberships_path, params: { email_address: "two@example.com" }
      delete church_membership_path(other)
    end
  end

  test "cannot remove members of another church" do
    delete church_membership_path(memberships(:two))

    assert_response :not_found
    assert Membership.exists?(memberships(:two).id)
  end
end
