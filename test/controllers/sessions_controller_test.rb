require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials" do
    post session_path, params: { email_address: @user.email_address, password: TEST_PASSWORD }

    assert_redirected_to root_path
    assert cookies[:session_id]
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "sessions end after a while without use" do
    sign_in_as @user
    Current.session.update_column(:updated_at, 31.days.ago)

    get hub_path
    assert_redirected_to new_session_path
  end

  test "using a session keeps it alive" do
    sign_in_as @user
    Current.session.update_column(:updated_at, 2.days.ago)

    get hub_path
    assert_response :success
    assert_in_delta Time.current, Current.session.reload.updated_at, 1.minute
  end

  test "destroy" do
    sign_in_as(User.take)

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
