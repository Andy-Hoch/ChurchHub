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

  test "privacy url must be http" do
    assert_not forms(:prayer).tap { |form| form.privacy_url = "javascript:alert(1)" }.valid?
    assert forms(:prayer).tap { |form| form.privacy_url = "https://example.com/datenschutz" }.valid?
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
