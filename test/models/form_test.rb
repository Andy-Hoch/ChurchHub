require "test_helper"

class FormTest < ActiveSupport::TestCase
  test "normalizes and validates notification emails" do
    form = forms(:prayer)
    form.notification_emails = "Pastor@Example.com; buero@example.com,  pastor@example.com"
    assert form.valid?
    assert_equal [ "pastor@example.com", "buero@example.com" ], form.notification_email_list

    form.notification_emails = "pastor@example.com, kaputt"
    assert_not form.valid?
  end

  test "changes invalidate the cached embed script" do
    hub = hubs(:one)
    hub.update_column(:updated_at, 1.day.ago)

    assert_changes -> { hub.reload.updated_at } do
      form_questions(:name).update!(label: "Dein Name?")
    end
  end

  test "creates forms from templates" do
    template = FormTemplate.find("prayer")
    form = template.build_for(churches(:one))

    assert form.save
    assert_equal "Gebetsanliegen", form.title
    assert_equal template.questions.size, form.questions.count
    assert_equal (0...template.questions.size).to_a, form.questions.map(&:position)
  end

  test "all templates are valid" do
    FormTemplate.all.each do |template|
      assert template.build_for(churches(:one)).valid?, "Vorlage #{template.key} ist ungültig"
    end
  end

  test "expired submissions depend on the retention period" do
    form = forms(:prayer)
    assert_empty form.expired_submissions

    form.update!(retention_months: 1)
    form_submissions(:read).update_column(:created_at, 2.months.ago)
    assert_equal [ form_submissions(:read) ], form.expired_submissions.to_a
  end

  test "deleting a form keeps its buttons but hides them" do
    link = hubs(:one).links.create!(title: "Gebet", kind: "form", form: forms(:prayer))
    forms(:prayer).destroy

    assert_nil link.reload.form
    assert_not link.embeddable?
  end
end

class FormAvailabilityTest < ActiveSupport::TestCase
  setup do
    @form = forms(:prayer)
    @link = hubs(:one).links.create!(title: "Gebet", kind: "form", form: @form)
  end

  test "is only open within its availability" do
    @form.update!(opens_at: Time.zone.parse("2026-11-01 00:00"), closes_at: Time.zone.parse("2026-11-08 00:00"))

    assert_not @form.open?(Time.zone.parse("2026-10-31 23:59"))
    assert @form.open?(Time.zone.parse("2026-11-01 00:00"))
    assert_not @form.open?(Time.zone.parse("2026-11-08 00:00"))
    assert_not @link.embeddable?(Time.zone.parse("2026-11-08 00:00"))
    assert @form.availability_ended?(Time.zone.parse("2026-11-08 00:00"))
  end

  test "closes when the submission limit is reached" do
    @form.update!(submission_limit: 3)
    assert_not @form.full?

    @form.update!(submission_limit: 2)
    assert @form.full?
    assert_not @form.open?
  end

  test "full forms are hidden or show a notice" do
    @form.update!(submission_limit: 2)
    assert_not @link.reload.embeddable?

    @form.update!(when_full: "notice")
    assert @link.reload.embeddable?
    assert_equal "Leider sind alle Plätze vergeben.", @link.embed_payload[:form][:closedMessage]

    @form.update!(full_message: "Ausgebucht!")
    assert_equal "Ausgebucht!", @link.reload.embed_payload[:form][:closedMessage]

    @form.update!(submission_limit: nil)
    assert_nil @link.reload.embed_payload[:form][:closedMessage]
  end

  test "validates availability and limit" do
    @form.assign_attributes(opens_at: 1.day.from_now, closes_at: 1.day.ago, submission_limit: 0)

    assert_not @form.valid?
    assert @form.errors.added?(:closes_at, :not_after_start)
    assert @form.errors.include?(:submission_limit)
  end

  test "hubs count submissions of all limited forms at once" do
    @form.update!(submission_limit: 2, when_full: "notice")
    hub = Hub.includes(links: :form).find(hubs(:one).id)

    assert_queries_count(1) { hub.shown_links }
    assert_includes hub.availability_key, "#{@link.id}-full"
  end
end
