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

class LinkScheduleTest < ActiveSupport::TestCase
  def sunday_livestream(**attributes)
    hubs(:one).links.create!(title: "Livestream", url: "https://example.com/live", schedule: "weekly", weekdays: %w[ 0 ], start_time: "08:00", end_time: "12:00", **attributes)
  end

  test "always shown without a schedule" do
    assert links(:live).schedule_always?
    assert links(:live).scheduled_at?(Time.zone.parse("2026-10-18 03:00"))
  end

  test "weekly links show on their weekdays between start and end time" do
    link = sunday_livestream

    assert link.scheduled_at?(Time.zone.parse("2026-10-18 08:00"))
    assert link.scheduled_at?(Time.zone.parse("2026-10-18 11:59"))
    assert_not link.scheduled_at?(Time.zone.parse("2026-10-18 07:59"))
    assert_not link.scheduled_at?(Time.zone.parse("2026-10-18 12:00"))
    assert_not link.scheduled_at?(Time.zone.parse("2026-10-19 09:00"))
    assert link.scheduled_at?(Time.zone.parse("2026-10-25 09:00")), "Sonntag der Zeitumstellung"
  end

  test "biweekly links skip every other week, counted from the first week" do
    link = sunday_livestream(schedule: "biweekly", visible_from: Time.zone.parse("2026-10-14 00:00"))

    assert link.scheduled_at?(Time.zone.parse("2026-10-18 09:00"))
    assert_not link.scheduled_at?(Time.zone.parse("2026-10-25 09:00"))
    assert link.scheduled_at?(Time.zone.parse("2026-11-01 09:00"))
    assert_not link.scheduled_at?(Time.zone.parse("2026-10-11 09:00")), "vor dem Start"
  end

  test "recurring and period links respect their bounds" do
    link = sunday_livestream(visible_until: Time.zone.parse("2026-10-20 00:00"))
    assert link.scheduled_at?(Time.zone.parse("2026-10-18 09:00"))
    assert_not link.scheduled_at?(Time.zone.parse("2026-10-25 09:00"))
    assert link.schedule_ended?(Time.zone.parse("2026-10-25 09:00"))

    period = hubs(:one).links.create!(title: "Freizeit", url: "https://example.com/freizeit", schedule: "period", visible_from: Time.zone.parse("2026-11-01 10:00"))
    assert_not period.scheduled_at?(Time.zone.parse("2026-11-01 09:59"))
    assert period.scheduled_at?(Time.zone.parse("2027-01-01 00:00"))
  end

  test "hidden links stay hidden whatever the schedule" do
    link = sunday_livestream(visible: false)

    assert_not link.embeddable?(Time.zone.parse("2026-10-18 09:00"))
  end

  test "validates the schedule" do
    link = hubs(:one).links.new(title: "Live", url: "https://example.com/live")

    link.schedule = "period"
    assert_not link.valid?
    assert link.errors.added?(:visible_from, :period_blank)

    link.assign_attributes(schedule: "weekly", weekdays: [ "" ], start_time: "12:00", end_time: "08:00")
    assert_not link.valid?
    assert link.errors.added?(:weekdays, :blank)
    assert link.errors.added?(:end_time, :not_after_start)

    link.assign_attributes(schedule: "biweekly", weekdays: %w[ 0 3 ], end_time: "13:00")
    assert_not link.valid?
    assert link.errors.added?(:visible_from, :first_week_blank)

    link.visible_from = Time.current
    assert link.valid?
    assert_equal [ 0, 3 ], link.weekdays
  end

  test "drops schedule details that do not apply" do
    link = sunday_livestream(visible_until: 1.year.from_now)
    link.update!(schedule: "always")

    assert_nil link.visible_until
    assert_empty link.weekdays
    assert_nil link.start_time
  end
end
