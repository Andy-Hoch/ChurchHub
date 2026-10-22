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

  test "saves a weekly schedule" do
    post hub_links_path, params: { link: { title: "Livestream", url: "https://example.com/live", visible: "1",
      schedule: "biweekly", weekdays: [ "", "0" ], start_time: "08:00", end_time: "12:00", visible_from: "2026-10-18T00:00" } }

    link = hubs(:one).links.find_by!(title: "Livestream")
    assert link.schedule_biweekly?
    assert_equal [ 0 ], link.weekdays
    assert_equal [ "08:00", "12:00" ], [ link.start_time, link.end_time ]
    assert_equal Time.zone.parse("2026-10-18 00:00"), link.visible_from
  end

  test "shows the schedule in the list" do
    links(:live).update!(schedule: "weekly", weekdays: [ 0 ], start_time: "08:00", end_time: "12:00")

    get hub_path
    assert_match "Jede Woche So 08:00–12:00", response.body
  end
end
