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

  test "shows form buttons and loads the launcher script without its button" do
    hubs(:one).links.create!(title: "Gebet", kind: "form", form: forms(:prayer))

    get public_hub_path(churches(:one).slug)

    assert_select "button.link[data-kirchen-hub-form=?]", forms(:prayer).id.to_s, text: /Gebet/
    assert_select "script[data-launcher=false][src=?]", embed_path(hubs(:one).public_token, format: :js)
  end

  test "skips the launcher script without form buttons" do
    get public_hub_path(churches(:one).slug)

    assert_select "script", count: 0
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
