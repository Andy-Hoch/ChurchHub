module ApplicationHelper
  def nav_link_to(name, path)
    link_to name, path, class: "btn sidebar-menu__button", aria: { current: ("page" if current_page?(path)) }
  end

  def field_error(record, attribute)
    return unless record.errors.include?(attribute)

    tag.p record.errors.full_messages_for(attribute).to_sentence, class: "field__error", id: "#{record.model_name.param_key}_#{attribute}_error"
  end

  def embed_snippet(hub)
    %(<script src="#{embed_url(hub.public_token, format: :js)}" async></script>)
  end
end
