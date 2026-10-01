# Self-hosted @font-face rules for the hub fonts (Google Fonts' latin and
# latin-ext subsets), so neither the public page nor the launcher on church
# websites contacts Google. URLs are absolute because the launcher injects
# these rules into the embedding page.
module HubFontsHelper
  # Keyed like Hub::FONT_FAMILIES, whose stacks start with these families.
  HUB_FONTS = {
    "sans" => { family: "Source Sans 3", file: "source-sans-3" },
    "serif" => { family: "Source Serif 4", file: "source-serif-4" }
  }.freeze
  HUB_FONT_SUBSETS = {
    "latin-ext" => "U+0100-02BA, U+02BD-02C5, U+02C7-02CC, U+02CE-02D7, U+02DD-02FF, U+0304, U+0308, U+0329, U+1D00-1DBF, U+1E00-1E9F, U+1EF2-1EFF, U+2020, U+20A0-20AB, U+20AD-20C0, U+2113, U+2C60-2C7F, U+A720-A7FF",
    "latin" => "U+0000-00FF, U+0131, U+0152-0153, U+02BB-02BC, U+02C6, U+02DA, U+02DC, U+0304, U+0308, U+0329, U+2000-206F, U+20AC, U+2122, U+2191, U+2193, U+2212, U+2215, U+FEFF, U+FFFD"
  }.freeze

  def hub_font_faces_css
    HUB_FONTS.values.flat_map do |font|
      HUB_FONT_SUBSETS.map do |subset, unicode_range|
        %(@font-face { font-family: "#{font[:family]}"; font-style: normal; font-weight: 200 900; font-display: swap; src: url("#{font_url("#{font[:file]}-#{subset}.woff2")}") format("woff2"); unicode-range: #{unicode_range}; })
      end
    end.join("\n").html_safe
  end

  # Safe: one of the fixed Hub::FONT_FAMILIES stacks, whose quotes must stay unescaped.
  def hub_font_stack(hub)
    Hub::FONT_FAMILIES.fetch(hub.font_family).html_safe
  end

  def hub_font_preload_tag(hub)
    file = HUB_FONTS.fetch(hub.font_family)[:file]
    tag.link rel: "preload", href: font_path("#{file}-latin.woff2"), as: "font", type: "font/woff2", crossorigin: "anonymous"
  end
end
