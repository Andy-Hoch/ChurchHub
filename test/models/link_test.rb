require "test_helper"

class LinkTest < ActiveSupport::TestCase
  test "only allows http and https urls" do
    assert Link.new(hub: hubs(:one), title: "Ok", url: "https://example.com").valid?
    assert_not Link.new(hub: hubs(:one), title: "Böse", url: "javascript:alert(1)").valid?
    assert_not Link.new(hub: hubs(:one), title: "Kaputt", url: "nicht eine url").valid?
  end

  test "appends new links to the end" do
    link = hubs(:one).links.create!(title: "Neu", url: "https://example.com/neu")

    assert_equal 3, link.position
  end

  test "move_to reorders siblings" do
    links(:hidden).move_to(0)

    assert_equal %w[ Intern Gottesdienst\ live Termine ], hubs(:one).links.reload.map(&:title)
    assert_equal [ 0, 1, 2 ], hubs(:one).links.map(&:position)
  end
end
