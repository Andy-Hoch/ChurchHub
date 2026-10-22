# When a link appears in the hub: always, within a period, or every (other)
# week on certain weekdays between two times, e.g. the livestream on Sundays
# from 8 to 12. Times are wall-clock times in the app's time zone.
module Link::Schedulable
  extend ActiveSupport::Concern

  ATTRIBUTES = %i[ schedule weekdays start_time end_time visible_from visible_until ].freeze
  RECURRING = %w[ weekly biweekly ].freeze
  # Monday first, as in German calendars.
  WEEKDAYS = [ 1, 2, 3, 4, 5, 6, 0 ].freeze
  TIME_FORMAT = /\A([01]\d|2[0-3]):[0-5]\d\z/

  included do
    enum :schedule, { always: "always", period: "period", weekly: "weekly", biweekly: "biweekly" }, prefix: true, validate: true

    normalizes :weekdays, with: ->(days) { Array(days).compact_blank.map(&:to_i).select { |day| day.in?(0..6) }.uniq.sort }
    normalizes :start_time, :end_time, with: ->(time) { time.strip.first(5).presence }

    validate :period_must_be_set, if: :schedule_period?
    validate :recurrence_must_be_complete, if: :recurring?
    validate :visible_until_must_follow_visible_from, unless: :schedule_always?

    before_save :clear_unused_schedule
  end

  def recurring?
    schedule.in?(RECURRING)
  end

  def scheduled_at?(time = Time.current)
    return true if schedule_always?

    within_bounds?(time) && (!recurring? || recurs_at?(time))
  end

  # The schedule will never show the link again.
  def schedule_ended?(time = Time.current)
    !schedule_always? && visible_until.present? && visible_until <= time
  end

  private
    def within_bounds?(time)
      (visible_from.nil? || visible_from <= time) && (visible_until.nil? || time < visible_until)
    end

    def recurs_at?(time)
      clock = time.strftime("%H:%M")

      time.wday.in?(weekdays) && start_time <= clock && clock < end_time && (schedule_weekly? || even_week?(time))
    end

    # Every other week, counted from the week of visible_from.
    def even_week?(time)
      first_week = visible_from.to_date.beginning_of_week(:monday)
      ((time.to_date.beginning_of_week(:monday) - first_week).to_i / 7).even?
    end

    def period_must_be_set
      errors.add(:visible_from, :period_blank) if visible_from.nil? && visible_until.nil?
    end

    def recurrence_must_be_complete
      errors.add(:weekdays, :blank) if weekdays.empty?
      errors.add(:visible_from, :first_week_blank) if schedule_biweekly? && visible_from.nil?

      if [ start_time, end_time ].all? { |time| time.to_s.match?(TIME_FORMAT) }
        errors.add(:end_time, :not_after_start) if end_time <= start_time
      else
        errors.add(:start_time, :invalid) unless start_time.to_s.match?(TIME_FORMAT)
        errors.add(:end_time, :invalid) unless end_time.to_s.match?(TIME_FORMAT)
      end
    end

    def visible_until_must_follow_visible_from
      errors.add(:visible_until, :not_after_start) if visible_from && visible_until && visible_until <= visible_from
    end

    def clear_unused_schedule
      self.visible_from = self.visible_until = nil if schedule_always?
      self.weekdays, self.start_time, self.end_time = [], nil, nil unless recurring?
    end
end
