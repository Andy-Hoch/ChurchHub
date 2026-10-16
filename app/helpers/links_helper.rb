module LinksHelper
  SCHEDULE_TIME_FORMAT = "%d.%m.%Y %H:%M"

  # [label, value] pairs from Monday to Sunday.
  def weekday_options
    Link::Schedulable::WEEKDAYS.map { |day| [ t("date.abbr_day_names")[day], day ] }
  end

  def schedule_name(schedule)
    t(schedule, scope: "activerecord.enums.link.schedule")
  end

  # Accordion title for one schedule option, e.g. "Button anzeigen (jede Woche)".
  def schedule_title(schedule)
    "Button anzeigen (#{t(schedule, scope: "links.schedule_titles")})"
  end

  # Accordion title for the saved schedule, with its details if it has any.
  def link_schedule_title(link)
    if (summary = link_schedule_summary(link).presence)
      "Button anzeigen (#{summary})"
    else
      schedule_title(link.schedule)
    end
  end

  # E.g. "Jede Woche So 08:00–12:00 · bis 31.12.2026 00:00".
  def link_schedule_summary(link)
    return if link.schedule_always?

    parts = []
    if link.recurring?
      days = link.weekdays.sort_by { |day| Link::Schedulable::WEEKDAYS.index(day) }.map { |day| t("date.abbr_day_names")[day] }
      parts << "#{schedule_name(link.schedule)} #{days.join(", ")} #{link.start_time}–#{link.end_time}"
    end
    parts << "ab #{l(link.visible_from, format: SCHEDULE_TIME_FORMAT)}" if link.visible_from
    parts << "bis #{l(link.visible_until, format: SCHEDULE_TIME_FORMAT)}" if link.visible_until
    parts.join(" · ")
  end

  # Why a link that is switched on is not shown right now, if it isn't.
  def link_status_badge(link)
    return unless link.visible?

    if link.schedule_ended?
      tag.span "Abgelaufen", class: "badge badge--secondary"
    elsif !link.scheduled_at?
      tag.span "Gerade nicht sichtbar", class: "badge badge--secondary"
    elsif link.kind_form? && link.form
      form_status_badge(link.form)
    end
  end
end
