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

  test "move_to moves down and clamps out-of-range positions" do
    links(:live).move_to(99)
    assert_equal %w[ Termine Intern Gottesdienst\ live ], hubs(:one).links.reload.map(&:title)

    links(:live).move_to(-5)
    assert_equal %w[ Gottesdienst\ live Termine Intern ], hubs(:one).links.reload.map(&:title)
  end

  test "move_to touches the hub so cached embeds pick up the new order" do
    hub = hubs(:one)
    hub.update_column(:updated_at, 1.day.ago)

    assert_changes -> { hub.reload.updated_at } do
      links(:hidden).move_to(0)
    end
  end
end

class LinkFormTest < ActiveSupport::TestCase
  test "form buttons need a form of the same church instead of a url" do
    assert Link.new(hub: hubs(:one), title: "Gebet", kind: "form", form: forms(:prayer)).valid?
    assert_not Link.new(hub: hubs(:one), title: "Gebet", kind: "form").valid?
    assert_not Link.new(hub: hubs(:one), title: "Fremd", kind: "form", form: forms(:other)).valid?
  end

  test "drops the target that does not match the kind" do
    link = links(:live)
    link.update!(kind: "form", form: forms(:prayer))
    assert_nil link.url

    link.update!(kind: "link", url: "https://example.com")
    assert_nil link.form
  end

  test "embeds the form with its questions" do
    link = hubs(:one).links.create!(title: "Gebet", kind: "form", form: forms(:prayer))
    payload = link.embed_payload

    assert_equal "form", payload[:type]
    assert_equal forms(:prayer).id, payload[:form][:id]
    assert_equal [ "Wofür dürfen wir beten?", "Wie heißt du?", "Wer darf davon erfahren?", "Deine E-Mail-Adresse" ], payload[:form][:questions].map { |question| question[:label] }
    assert_equal [ "Nur das Gebetsteam", "Die ganze Gemeinde" ], payload[:form][:questions].third[:choices]
  end
end
