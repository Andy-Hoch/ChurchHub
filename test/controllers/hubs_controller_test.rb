require "test_helper"

class HubsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "requires authentication" do
    sign_out
    get hub_path
    assert_redirected_to new_session_path
  end

  test "shows only the links of the current church" do
    get hub_path

    assert_response :success
    assert_match "Gottesdienst live", response.body
    assert_no_match "Andere Kirche", response.body
  end

  test "design page renders the live preview" do
    get edit_hub_path

    assert_response :success
    assert_match "data-kirchen-hub", response.body
  end

  test "updates the theme" do
    patch hub_path, params: { hub: { primary_color: "#AA0000", position: "left" } }

    assert_redirected_to edit_hub_path
    assert_equal "oklch(46.34% 0.1902 29.23)", hubs(:one).reload.primary_color
    assert_equal "left", hubs(:one).position
  end

  test "rejects an invalid theme" do
    patch hub_path, params: { hub: { primary_color: "rot" } }
    assert_response :unprocessable_entity
  end

  test "regenerates the public token" do
    assert_changes -> { hubs(:one).reload.public_token } do
      post regenerate_token_hub_path
    end
  end
end
