require "test_helper"

class HubTest < ActiveSupport::TestCase
  test "validates theme values" do
    hub = hubs(:one)
    hub.assign_attributes(primary_color: "red", position: "top", color_scheme: "neon", button_icon: "x", corner_radius: 99, font_family: "comic")

    assert_not hub.valid?
    assert_equal %i[ primary_color position color_scheme button_icon corner_radius font_family ].sort, hub.errors.attribute_names.sort
  end

  test "embed payload contains only visible links in order" do
    payload = hubs(:one).embed_payload

    assert_equal [ "Gottesdienst live", "Termine" ], payload[:links].map { |link| link[:title] }
    assert_equal "oklch(21.03% 0.0059 285.89)", payload[:theme][:primaryColor]
    assert_equal "sans", payload[:theme][:fontFamily]
  end

  test "converts hex colors from the color picker to oklch" do
    hub = hubs(:one)
    hub.update!(primary_color: "#AA0000", text_color: "oklch(100% 0 0)")

    assert_equal "oklch(46.34% 0.1902 29.23)", hub.primary_color
    assert_equal "oklch(100% 0 0)", hub.text_color
    assert_equal "#aa0000", hub.primary_color_hex
    assert_equal "#ffffff", hub.text_color_hex
  end
end
