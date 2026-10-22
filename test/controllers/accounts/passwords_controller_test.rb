require "test_helper"

class Accounts::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
  end

  test "changes the password" do
    patch account_password_path, params: { current_password: TEST_PASSWORD, password: "neues-passwort", password_confirmation: "neues-passwort" }

    assert_redirected_to edit_account_path
    assert_equal "Dein Passwort wurde geändert.", flash[:notice]
    assert @user.reload.authenticate("neues-passwort")
  end

  test "does not change the password with a wrong current password" do
    patch account_password_path, params: { current_password: "falsch", password: "neues-passwort", password_confirmation: "neues-passwort" }

    assert_redirected_to edit_account_path
    assert_equal "Das aktuelle Passwort ist falsch.", flash[:alert]
    assert @user.reload.authenticate(TEST_PASSWORD)
  end

  test "does not change the password when the confirmation does not match" do
    patch account_password_path, params: { current_password: TEST_PASSWORD, password: "neues-passwort", password_confirmation: "anderes-passwort" }

    assert_redirected_to edit_account_path
    assert flash[:alert]
    assert @user.reload.authenticate(TEST_PASSWORD)
  end

  test "does not change the password when it is too short" do
    patch account_password_path, params: { current_password: TEST_PASSWORD, password: "kurz", password_confirmation: "kurz" }

    assert flash[:alert]
    assert @user.reload.authenticate(TEST_PASSWORD)
  end

  test "does not report success for a blank password" do
    patch account_password_path, params: { current_password: TEST_PASSWORD, password: "", password_confirmation: "" }

    assert flash[:alert]
    assert @user.reload.authenticate(TEST_PASSWORD)
  end

  test "signs out other sessions but keeps the current one" do
    other_session = @user.sessions.create!

    patch account_password_path, params: { current_password: TEST_PASSWORD, password: "neues-passwort", password_confirmation: "neues-passwort" }

    assert_not Session.exists?(other_session.id)
    get edit_account_path
    assert_response :success
  end
end
