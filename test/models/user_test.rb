require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires name and a password of at least 8 characters" do
    user = User.new(email_address: "neu@example.com", password: "kurz")

    assert_not user.valid?
    assert_includes user.errors.attribute_names, :name
    assert_includes user.errors.attribute_names, :password
  end
end
