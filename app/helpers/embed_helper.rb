# Glue between a hub and the static launcher in app/javascript/embed/widget.js.
module EmbedHelper
  EMBED_WIDGET = "embed/widget.js"

  def embed_snippet(hub)
    %(<script src="#{embed_url(hub.public_token, format: :js)}" async></script>)
  end

  # Everything KirchenHub.mount needs to know about the hub, as a JSON string
  # that is safe inside a <script> element.
  def embed_config_json(hub, allowed_hosts: nil)
    config = { hub: hub.embed_payload, allowedHosts: allowed_hosts, fonts: Hub::FONT_FAMILIES, fontFaces: hub_font_faces_css }
    json_escape(config.to_json).html_safe
  end

  def embed_widget_source
    embed_widget_asset.content(encoding: "UTF-8").html_safe
  end

  def embed_widget_asset
    Rails.application.assets.load_path.find(EMBED_WIDGET)
  end
end
