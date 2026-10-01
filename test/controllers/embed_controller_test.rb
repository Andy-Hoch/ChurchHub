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

  test "ships absolute URLs to the self-hosted hub fonts" do
    get embed_path(hubs(:one).public_token, format: :js)

    assert_match %r{url\(\\"http://www\.example\.com/assets/source-sans-3-latin-\h+\.woff2\\"\)}, response.body
    assert_match %("serif":"\\"Source Serif 4\\", Georgia), response.body
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

  test "serves the script on the church website and its subdomains" do
    [ "https://gemeinde-eins.example/", "https://www.gemeinde-eins.example/kontakt", "https://jugend.gemeinde-eins.example/" ].each do |referer|
      get embed_path(hubs(:one).public_token, format: :js), headers: { "Referer" => referer }

      assert_match "Gottesdienst live", response.body, referer
      assert_match "gemeinde-eins.example", response.body
    end
    assert_equal "Referer", response.headers["Vary"]
  end

  test "refuses to serve the script on foreign websites" do
    [ "https://fremd.example/", "https://gemeinde-eins.example.fremd.example/" ].each do |referer|
      get embed_path(hubs(:one).public_token, format: :js), headers: { "Referer" => referer }

      assert_response :success
      assert_match "nicht freigegeben", response.body
      assert_no_match "Gottesdienst", response.body
    end
  end

  test "lets the script check the page host when no referer is sent" do
    get embed_path(hubs(:one).public_token, format: :js)

    assert_match "Gottesdienst live", response.body
    assert_match %(["gemeinde-eins.example","www.example.com"]), response.body
  end

  test "serves the script everywhere when the church has no website" do
    churches(:one).update!(website_url: "")
    get embed_path(hubs(:one).public_token, format: :js), headers: { "Referer" => "https://fremd.example/" }

    assert_match "Gottesdienst live", response.body
    assert_match "var allowedHosts = null;", response.body
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
