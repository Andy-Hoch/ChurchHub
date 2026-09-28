class FormSubmission < ApplicationRecord
  belongs_to :form

  scope :unread, -> { where(read_at: nil) }

  validate { errors.add(:answers, :invalid) if answer_errors.any? }

  # Answers are stored together with the question label at the time of
  # submission, so later edits to the form do not change old submissions.
  def self.build_from(form, raw_answers)
    raw_answers = raw_answers.to_h.stringify_keys
    submission = form.submissions.new

    submission.answers = form.questions.map do |question|
      value, error = question.parse_answer(raw_answers[question.id.to_s])
      submission.answer_errors[question.id] = error if error
      { "question_id" => question.id, "label" => question.label, "kind" => question.kind, "value" => value }
    end

    submission
  end

  # Question id => error message, filled by .build_from.
  def answer_errors
    @answer_errors ||= {}
  end

  def read?
    read_at.present?
  end

  def mark_read!
    update!(read_at: Time.current) unless read?
  end

  def toggle_read!
    update!(read_at: read? ? nil : Time.current)
  end

  # Short preview for lists: the first answered text.
  def excerpt
    answers.lazy.map { |answer| self.class.format_value(answer) }.find(&:present?).to_s.truncate(100)
  end

  def self.format_value(answer)
    value = answer["value"]

    case value
    when nil, "" then nil
    when Array then value.join(", ")
    else
      answer["kind"] == "date" ? I18n.l(Date.iso8601(value)) : value.to_s
    end
  rescue Date::Error
    value.to_s
  end
end
