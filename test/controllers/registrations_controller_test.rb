require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path
    assert_response :success
  end

  test "creates user, church, owner membership and hub" do
    assert_difference [ "User.count", "Church.count", "Membership.count", "Hub.count" ], 1 do
      post registration_path, params: {
        church: { name: "St. Paulus" },
        user: { name: "Clara", email_address: "clara@example.com", password: "geheim123", password_confirmation: "geheim123" }
      }
    end

    assert_redirected_to hub_path
    assert cookies[:session_id]
    user = User.find_by!(email_address: "clara@example.com")
    assert user.memberships.first.owner?
    assert_equal "st-paulus", user.churches.first.slug
  end

  test "renders errors without creating anything" do
    assert_no_difference [ "User.count", "Church.count" ] do
      post registration_path, params: { church: { name: "" }, user: { name: "", email_address: "x", password: "1" } }
    end

    assert_response :unprocessable_entity
  end
end
