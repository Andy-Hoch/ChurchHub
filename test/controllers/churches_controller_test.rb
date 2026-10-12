require "test_helper"

class ChurchesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "creates a church owned by the user and switches to it" do
    assert_difference [ "Church.count", "Hub.count" ] do
      post churches_path, params: { church: { name: "Neue Gemeinde" } }
    end

    church = Church.find_by!(name: "Neue Gemeinde")
    assert church.memberships.find_by!(user: users(:one)).owner?
    assert_redirected_to hub_path

    follow_redirect!
    assert_select "header", /Neue Gemeinde/
  end

  test "rejects an invalid church" do
    assert_no_difference [ "Church.count", "Membership.count" ] do
      post churches_path, params: { church: { name: "" } }
    end

    assert_response :unprocessable_entity
  end
end
