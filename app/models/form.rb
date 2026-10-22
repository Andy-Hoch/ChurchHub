class Form < ApplicationRecord
  RETENTION_OPTIONS = [ 1, 3, 6, 12, 24 ].freeze

  belongs_to :church
  has_many :questions, -> { order(:position, :id) }, class_name: "FormQuestion", dependent: :destroy, inverse_of: :form
  has_many :submissions, -> { order(created_at: :desc, id: :desc) }, class_name: "FormSubmission", dependent: :delete_all, inverse_of: :form
  has_many :links, dependent: :nullify

  enum :when_full, { hide: "hide", notice: "notice" }, prefix: true, validate: true

  normalizes :notification_emails, with: ->(emails) { emails.split(/[\s,;]+/).compact_blank.map(&:downcase).uniq.join(", ").presence }
  normalizes :submit_label, with: ->(value) { value.strip.presence }

  validates :title, presence: true, length: { maximum: 80 }
  validates :intro, :thank_you_message, :full_message, length: { maximum: 1000 }
  validates :submit_label, length: { maximum: 30 }
  validates :retention_months, numericality: { only_integer: true, in: 1..120 }, allow_nil: true
  validates :submission_limit, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validate :notification_emails_must_be_valid
  validate :closes_at_must_follow_opens_at

  # The embed script is cached by the hub's timestamp.
  after_save :touch_hub
  after_touch :touch_hub
  after_destroy :touch_hub

  def notification_email_list
    notification_emails.to_s.split(", ")
  end

  delegate :consent_required?, to: :church

  # Hubs load the counts of all their forms at once, see Hub#shown_links.
  attr_writer :submissions_count

  def submissions_count
    @submissions_count || submissions.count
  end

  def full?
    submission_limit.present? && submissions_count >= submission_limit
  end

  def within_availability?(time = Time.current)
    (opens_at.nil? || opens_at <= time) && (closes_at.nil? || time < closes_at)
  end

  def availability_ended?(time = Time.current)
    closes_at.present? && closes_at <= time
  end

  # Accepts submissions right now.
  def open?(time = Time.current)
    within_availability?(time) && !full?
  end

  # Full forms either disappear from the hub or show a notice instead of their questions.
  def shown_in_hub?(time = Time.current)
    within_availability?(time) && (when_full_notice? || !full?)
  end

  def closed_message
    full_message.presence || I18n.t("forms.full_message")
  end

  def expired_submissions
    return FormSubmission.none unless retention_months

    FormSubmission.where(form: self, created_at: ...retention_months.months.ago)
  end

  def embed_payload
    {
      id: id,
      title: title,
      intro: intro.presence,
      thankYou: thank_you_message.presence,
      submitLabel: submit_label.presence,
      closedMessage: (closed_message if full?),
      questions: questions.map(&:embed_payload)
    }
  end

  private
    def notification_emails_must_be_valid
      invalid = notification_email_list.grep_v(URI::MailTo::EMAIL_REGEXP)
      errors.add(:notification_emails, :invalid_addresses, addresses: invalid.join(", ")) if invalid.any?
    end

    def closes_at_must_follow_opens_at
      errors.add(:closes_at, :not_after_start) if opens_at && closes_at && closes_at <= opens_at
    end

    def touch_hub
      hub = church.hub
      hub.touch if hub&.persisted?
    end
end
