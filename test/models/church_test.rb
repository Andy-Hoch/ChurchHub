require "test_helper"

class ChurchTest < ActiveSupport::TestCase
  test "generates a unique slug and a default hub" do
    church = Church.create!(name: "Gemeinde Eins")

    assert_equal "gemeinde-eins-2", church.slug
    assert_equal "Gemeinde Eins", church.hub.title
    assert church.hub.public_token.present?
  end

  test "normalizes slug" do
    assert_equal "st-marien", Church.new(slug: "St. Marien").slug
  end

  test "rejects slugs reserved for app routes" do
    church = Church.new(name: "Hub", slug: "hub")
    assert_not church.valid?
    assert church.errors.of_kind?(:slug, :exclusion)

    assert_equal "embed-2", Church.create!(name: "Embed").slug
  end
end
