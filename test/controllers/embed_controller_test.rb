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

  test "a new widget version is not answered with not modified" do
    get embed_path(hubs(:one).public_token, format: :js)
    etag = response.headers["ETag"]

    load_path = Rails.application.assets.load_path
    changed = Data.define(:digest) { def content(encoding:) = "/* neu */" }.new("changed")
    load_path.define_singleton_method(:find) { |path| path == EmbedHelper::EMBED_WIDGET ? changed : super(path) }
    begin
      get embed_path(hubs(:one).public_token, format: :js), headers: { "If-None-Match" => etag }
    ensure
      load_path.singleton_class.remove_method(:find)
    end

    assert_response :success
    assert_match "/* neu */", response.body
  end

  test "ships the static widget together with the hub data" do
    get embed_path(hubs(:one).public_token, format: :js)

    assert response.body.start_with?(Rails.application.assets.load_path.find(EmbedHelper::EMBED_WIDGET).content(encoding: "UTF-8"))
    assert_match "KirchenHub.mount({", response.body
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
    assert_match %("allowedHosts":null), response.body
  end

  test "returns harmless script for disabled or unknown hubs" do
    hubs(:one).update!(enabled: false)

    get embed_path(hubs(:one).public_token, format: :js)
    assert_response :success
    assert_no_match "Gottesdienst", response.body

    get embed_path("unbekannt", format: :js)
    assert_response :success
  end

  test "scheduled links appear in their time window, even for cached scripts" do
    hubs(:one).links.create!(title: "Livestream", url: "https://example.com/stream", schedule: "weekly", weekdays: %w[ 0 ], start_time: "08:00", end_time: "12:00")

    travel_to Time.zone.parse("2026-10-18 07:55") do
      get embed_path(hubs(:one).public_token, format: :js)
      assert_no_match "Livestream", response.body
    end
    etag = response.headers["ETag"]

    travel_to Time.zone.parse("2026-10-18 08:05") do
      get embed_path(hubs(:one).public_token, format: :js), headers: { "If-None-Match" => etag }
      assert_response :success
      assert_match "Livestream", response.body
    end
  end

  test "full forms with a notice ship the notice instead of being dropped" do
    hubs(:one).links.create!(title: "Anmeldung", kind: "form", form: forms(:prayer))
    forms(:prayer).update!(submission_limit: 2, when_full: "notice", full_message: "Alle Plätze sind weg.")

    get embed_path(hubs(:one).public_token, format: :js)

    assert_match "Anmeldung", response.body
    assert_match "Alle Plätze sind weg.", response.body
  end
end
