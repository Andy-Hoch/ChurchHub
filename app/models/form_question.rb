class FormQuestion < ApplicationRecord
  include Positionable

  KINDS = {
    "short_text" => "Kurzer Text",
    "long_text" => "Langer Text",
    "single_choice" => "Einfachauswahl",
    "multiple_choice" => "Mehrfachauswahl",
    "yes_no" => "Ja / Nein",
    "email" => "E-Mail-Adresse",
    "phone" => "Telefonnummer",
    "number" => "Zahl",
    "date" => "Datum"
  }.freeze
  CHOICE_KINDS = %w[ single_choice multiple_choice ].freeze
  YES_NO = %w[ Ja Nein ].freeze
  MAX_LENGTH = { "short_text" => 200, "long_text" => 5000 }.freeze
  PHONE_FORMAT = %r{\A\+?[\d\s()/.-]{5,30}\z}

  belongs_to :form, touch: true

  enum :kind, KINDS.keys.index_by(&:itself), prefix: true, validate: true

  positioned_within :form, :questions

  validates :label, presence: true, length: { maximum: 200 }
  validates :help_text, length: { maximum: 300 }
  validate :choices_must_be_present, if: :choice_kind?

  before_save :clear_choices, unless: :choice_kind?

  def kind_name
    KINDS[kind]
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
  def parse_answer(raw)
    value = kind_multiple_choice? ? Array(raw).map { |item| item.to_s.strip }.compact_blank : raw.to_s.strip.presence

    if value.blank?
      [ nil, (required? ? "Bitte beantworte diese Frage." : nil) ]
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
      case kind
      when "short_text", "long_text"
        "Bitte höchstens #{MAX_LENGTH[kind]} Zeichen." if value.length > MAX_LENGTH[kind]
      when "email"
        "Bitte gib eine gültige E-Mail-Adresse ein." unless value.match?(URI::MailTo::EMAIL_REGEXP)
      when "phone"
        "Bitte gib eine gültige Telefonnummer ein." unless value.match?(PHONE_FORMAT)
      when "number"
        "Bitte gib eine Zahl ein." unless value.match?(/\A-?\d+([.,]\d+)?\z/)
      when "date"
        "Bitte gib ein gültiges Datum ein." unless valid_date?(value)
      when "yes_no"
        "Bitte wähle Ja oder Nein." unless value.in?(YES_NO)
      when "single_choice"
        "Bitte wähle eine der Möglichkeiten." unless value.in?(choices)
      when "multiple_choice"
        "Bitte wähle aus den Möglichkeiten." unless (value - choices).empty?
      end
    end

    def valid_date?(value)
      value.match?(/\A\d{4}-\d{2}-\d{2}\z/) && Date.iso8601(value)
    rescue Date::Error
      false
    end

    def choices_must_be_present
      if choices.blank?
        errors.add(:choices, "brauchen mindestens eine Möglichkeit")
      elsif choices.size > 30 || choices.any? { |choice| choice.length > 100 }
        errors.add(:choices, "dürfen höchstens 30 Einträge mit je 100 Zeichen sein")
      end
    end

    def clear_choices
      self.choices = []
    end
end
