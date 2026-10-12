require "test_helper"

class OklchColorTest < ActiveSupport::TestCase
  test "converts hex to oklch and back" do
    %w[ #000000 #ffffff #aa0000 #1e90ff #7fff00 ].each do |hex|
      assert_equal hex, OklchColor.to_hex(OklchColor.normalize(hex)), "#{hex} should survive the round trip"
    end
  end

  test "accepts hex without hash and in upper case" do
    assert_equal OklchColor.normalize("#aa0000"), OklchColor.normalize("AA0000")
  end

  test "normalizes oklch strings to the stored format" do
    assert_equal "oklch(50% 0.1 120)", OklchColor.normalize(" OKLCH( 50.00%  0.1000 120 ) ")
    assert_equal "oklch(50% 0 0)", OklchColor.normalize("oklch(50% 0.00001 200)")
    assert_match OklchColor::FORMAT, OklchColor.normalize("#1e90ff")
  end

  test "returns nil for values it cannot parse" do
    [ nil, "", "red", "#12345", "rgb(0, 0, 0)", "oklch(50 0.1 120)" ].each do |value|
      assert_nil OklchColor.normalize(value), "#{value.inspect} should not parse"
      assert_nil OklchColor.to_hex(value)
    end
  end
end
