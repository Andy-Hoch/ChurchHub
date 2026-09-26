require "test_helper"

class PublicHubsControllerTest < ActionDispatch::IntegrationTest
  test "shows the hub as a standalone page without login" do
    get public_hub_path(churches(:one).slug)

    assert_response :success
    assert_select "h1", "Gemeinde Eins"
    assert_match "Gottesdienst live", response.body
    assert_no_match "Intern", response.body
    assert_select "meta[name=viewport]"
  end

  test "returns not found for unknown churches and disabled hubs" do
    get public_hub_path("unbekannt")
    assert_response :not_found

    hubs(:one).update!(enabled: false)
    get public_hub_path(churches(:one).slug)
    assert_response :not_found
  end

  test "app routes take precedence over slugs" do
    assert_recognizes({ controller: "sessions", action: "new" }, "/session/new")
    assert_recognizes({ controller: "public_hubs", action: "show", slug: "gemeinde-eins" }, "/gemeinde-eins")
  end
end
