require "test_helper"

class HubTest < ActiveSupport::TestCase
  test "validates theme values" do
    hub = hubs(:one)
    hub.assign_attributes(primary_color: "red", position: "top", color_scheme: "neon", button_icon: "x", corner_radius: 99)

    assert_not hub.valid?
    assert_equal %i[ primary_color position color_scheme button_icon corner_radius ].sort, hub.errors.attribute_names.sort
  end

  test "embed payload contains only visible links in order" do
    payload = hubs(:one).embed_payload

    assert_equal [ "Gottesdienst live", "Termine" ], payload[:links].map { |link| link[:title] }
    assert_equal "#18181b", payload[:theme][:primaryColor]
  end
end
