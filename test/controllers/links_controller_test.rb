require "test_helper"

class LinksControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in_as users(:one) }

  test "creates a link" do
    assert_difference -> { hubs(:one).links.count } do
      post hub_links_path, params: { link: { title: "Kontakt", url: "https://example.com/kontakt", visible: "1" } }
    end
    assert_redirected_to hub_path
  end

  test "rejects unsafe urls" do
    assert_no_difference "Link.count" do
      post hub_links_path, params: { link: { title: "XSS", url: "javascript:alert(1)" } }
    end
    assert_response :unprocessable_entity
  end

  test "updates a link" do
    patch hub_link_path(links(:live)), params: { link: { title: "Livestream" } }
    assert_equal "Livestream", links(:live).reload.title
  end

  test "destroys a link" do
    assert_difference "Link.count", -1 do
      delete hub_link_path(links(:live))
    end
  end

  test "reorders a link" do
    put position_hub_link_path(links(:events)), params: { position: 0 }

    assert_response :no_content
    assert_equal [ "Termine", "Gottesdienst live", "Intern" ], hubs(:one).links.reload.map(&:title)
  end

  test "cannot touch links of another church" do
    patch hub_link_path(links(:other)), params: { link: { title: "Gehackt" } }

    assert_response :not_found
    assert_equal "Andere Kirche", links(:other).reload.title
  end
end
