require "test_helper"

class EmbedControllerTest < ActionDispatch::IntegrationTest
  test "serves the launcher script without login, even cross-origin" do
    get embed_path(hubs(:one).public_token, format: :js), headers: { "Origin" => "https://kirche.example", "Sec-Fetch-Site" => "cross-site" }

    assert_response :success
    assert_equal "text/javascript", response.media_type
    assert_match "Gottesdienst live", response.body
    assert_no_match "Intern", response.body
    assert_match "public", response.headers["Cache-Control"]
  end

  test "escapes link data inside the script" do
    links(:live).update!(title: "</script><script>alert(1)</script>")
    get embed_path(hubs(:one).public_token, format: :js)

    assert_no_match "</script>", response.body
  end

  test "returns not modified for an unchanged hub" do
    get embed_path(hubs(:one).public_token, format: :js)
    etag = response.headers["ETag"]

    get embed_path(hubs(:one).public_token, format: :js), headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end

  test "returns harmless script for disabled or unknown hubs" do
    hubs(:one).update!(enabled: false)

    get embed_path(hubs(:one).public_token, format: :js)
    assert_response :success
    assert_no_match "Gottesdienst", response.body

    get embed_path("unbekannt", format: :js)
    assert_response :success
  end
end
