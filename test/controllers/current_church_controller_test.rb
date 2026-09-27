require "test_helper"

class CurrentChurchControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "owner updates the church" do
    patch church_path, params: { church: { name: "Neuer Name" } }

    assert_redirected_to edit_church_path
    assert_equal "Neuer Name", churches(:one).reload.name
  end

  test "admins cannot update the church" do
    memberships(:one).update!(role: :admin)
    patch church_path, params: { church: { name: "Neuer Name" } }

    assert_equal "Gemeinde Eins", churches(:one).reload.name
  end

  test "owner adds and removes a member" do
    assert_difference -> { churches(:one).memberships.count } do
      post church_memberships_path, params: { email_address: "two@example.com" }
    end

    membership = churches(:one).memberships.find_by!(user: users(:two))
    assert membership.admin?

    assert_difference -> { churches(:one).memberships.count }, -1 do
      delete church_membership_path(membership)
    end
  end

  test "switches between churches" do
    churches(:two).memberships.create!(user: users(:one))

    patch church_switch_path, params: { church_id: churches(:two).id }
    get hub_path

    assert_match "Andere Kirche", response.body
  end
end
