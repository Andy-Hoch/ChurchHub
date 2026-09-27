require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "edit" do
    get edit_account_path

    assert_response :success
    assert_match "one@example.com", response.body
    assert_match "Wird gelöscht", response.body
  end

  test "does not delete the account with a wrong password" do
    assert_no_difference [ "User.count", "Church.count" ] do
      delete account_path, params: { password: "falsch" }
    end

    assert_redirected_to edit_account_path
  end

  test "deletes the account and churches without other members" do
    church = churches(:one)

    assert_difference [ "User.count", "Church.count" ], -1 do
      delete account_path, params: { password: "password" }
    end

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
    assert_not Church.exists?(church.id)

    get hub_path
    assert_redirected_to new_session_path
  end

  test "hands churches with other members over to them" do
    churches(:one).memberships.create!(user: users(:two), role: :admin)

    assert_no_difference "Church.count" do
      delete account_path, params: { password: "password" }
    end

    assert churches(:one).memberships.find_by!(user: users(:two)).owner?
  end
end
