require "test_helper"

class ChurchSwitchesControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "cannot switch to a church the user does not belong to" do
    patch church_switch_path, params: { church_id: churches(:two).id }

    assert_response :not_found
  end

  test "falls back to another church after losing access to the chosen one" do
    churches(:two).memberships.create!(user: users(:one))
    patch church_switch_path, params: { church_id: churches(:two).id }

    churches(:two).memberships.find_by!(user: users(:one)).destroy!
    get hub_path

    assert_response :success
    assert_select "header", /Gemeinde Eins/
  end
end
