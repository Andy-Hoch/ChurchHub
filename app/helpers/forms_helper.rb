module FormsHelper
  # Why a form is not available right now, if it isn't.
  def form_status_badge(form)
    if form.availability_ended?
      tag.span "Abgelaufen", class: "badge badge--secondary"
    elsif !form.within_availability?
      tag.span "Ab #{l(form.opens_at, format: LinksHelper::SCHEDULE_TIME_FORMAT)}", class: "badge badge--secondary"
    elsif form.full?
      tag.span(form.when_full_notice? ? "Voll – zeigt Hinweis" : "Voll – ausgeblendet", class: "badge badge--secondary")
    end
  end
end
