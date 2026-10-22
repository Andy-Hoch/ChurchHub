module PickersHelper
  # A datetime-local field that the date-time-picker controller turns into a
  # rolldate calendar with a time roll, labelled in German.
  def date_time_picker_field(form, attribute, data: {})
    form.datetime_local_field attribute, class: "input", data: {
      controller: "date-time-picker",
      date_time_picker_month_names_value: t("date.month_names").compact,
      date_time_picker_short_month_names_value: t("date.abbr_month_names").compact,
      date_time_picker_day_names_value: t("date.abbr_day_names"),
      **data
    }
  end

  # A 24-hour "HH:MM" text field with an hour and a minute roll to pick from.
  def time_roller_field(form, attribute, required: false, data: {})
    render "shared/time_roller", form:, attribute:, required:, data:
  end
end
