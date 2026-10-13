class FormQuestion < ApplicationRecord
  include Positionable

  KINDS = %w[ short_text long_text single_choice multiple_choice yes_no email phone number date ].freeze
  CHOICE_KINDS = %w[ single_choice multiple_choice ].freeze
  # The values the launcher submits for yes/no questions; stored as they are.
  YES_NO = %w[ Ja Nein ].freeze
  MAX_LENGTH = { "short_text" => 200, "long_text" => 5000 }.freeze
  PHONE_FORMAT = %r{\A\+?[\d\s()/.-]{5,30}\z}

  belongs_to :form, touch: true

  enum :kind, KINDS.index_by(&:itself), prefix: true, validate: true

  positioned_within :form, :questions

  validates :label, presence: true, length: { maximum: 200 }
  validates :help_text, length: { maximum: 300 }
  validate :choices_must_be_present, if: :choice_kind?

  before_save :clear_choices, unless: :choice_kind?

  # [name, kind] pairs for a select.
  def self.kind_options
    KINDS.map { |kind| [ kind_name(kind), kind ] }
  end

  def self.kind_name(kind)
    I18n.t(kind, scope: "activerecord.enums.form_question.kind")
  end

  def kind_name
    self.class.kind_name(kind)
  end

  def choice_kind?
    kind.in?(CHOICE_KINDS)
  end

  # Admins enter one choice per line.
  def choices_text
    Array(choices).join("\n")
  end

  def choices_text=(text)
    self.choices = text.to_s.lines.map(&:strip).compact_blank.uniq
  end

  # Checks a submitted answer and returns [value, error]. The value is what
  # gets stored: stripped strings, an array for multiple choice, nil when empty.
  # Anything that isn't a string (e.g. nested params) counts as no answer.
  def parse_answer(raw)
    value = kind_multiple_choice? ? Array(raw).grep(String).map(&:strip).compact_blank : (raw.strip.presence if raw.is_a?(String))

    if value.blank?
      [ nil, (answer_error_message(:required) if required?) ]
    else
      [ value, answer_error(value) ]
    end
  end

  def embed_payload
    {
      id: id,
      kind: kind,
      label: label,
      help: help_text.presence,
      required: required?,
      choices: choice_kind? ? choices : nil,
      maxLength: MAX_LENGTH[kind]
    }.compact
  end

  private
    def answer_error(value)
      valid =
        case kind
        when "short_text", "long_text" then value.length <= MAX_LENGTH[kind]
        when "email" then value.match?(URI::MailTo::EMAIL_REGEXP)
        when "phone" then value.match?(PHONE_FORMAT)
        when "number" then value.match?(/\A-?\d+([.,]\d+)?\z/)
        when "date" then valid_date?(value)
        when "yes_no" then value.in?(YES_NO)
        when "single_choice" then value.in?(choices)
        when "multiple_choice" then (value - choices).empty?
        end

      answer_error_message(kind, max: MAX_LENGTH[kind]) unless valid
    end

    # Shown to visitors in the launcher, next to the question.
    def answer_error_message(key, **options)
      I18n.t(key, scope: "activerecord.errors.models.form_question.answers", **options)
    end

    def valid_date?(value)
      value.match?(/\A\d{4}-\d{2}-\d{2}\z/) && Date.iso8601(value)
    rescue Date::Error
      false
    end

    def choices_must_be_present
      if choices.blank?
        errors.add(:choices, :missing)
      elsif choices.size > 30 || choices.any? { |choice| choice.length > 100 }
        errors.add(:choices, :too_many_or_too_long, max: 30, length: 100)
      end
    end

    def clear_choices
      self.choices = []
    end
end
