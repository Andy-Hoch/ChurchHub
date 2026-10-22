module ApplicationHelper
  # Section links stay current on the pages below them, e.g. a form's questions and submissions.
  def nav_link_to(name, path, badge: nil, section: false)
    current = section ? request.path == path || request.path.start_with?("#{path}/") : current_page?(path)

    link_to path, class: "btn sidebar-menu__button", title: name, aria: { current: ("page" if current) } do
      safe_join([ tag.span(name, class: "sidebar-menu__label"), (tag.span(badge, class: "badge badge--primary mis-auto") if badge) ])
    end
  end

  def sidebar_forms
    @sidebar_forms ||= current_church ? current_church.forms.order(:title).to_a : []
  end

  def unread_counts_by_form
    @unread_counts_by_form ||= FormSubmission.unread.where(form: sidebar_forms).group(:form_id).count
  end

  def unread_submissions_count
    unread_counts_by_form.values.sum
  end

  def field_error(record, attribute)
    return unless record.errors.include?(attribute)

    tag.p record.errors.full_messages_for(attribute).to_sentence, class: "field__error", id: "#{record.model_name.param_key}_#{attribute}_error"
  end
end
