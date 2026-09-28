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
    assert_equal "account-2", Church.create!(name: "Account").slug
  end

  test "website is optional and normalized" do
    assert Church.new(name: "Ohne Webseite").valid?
    assert_nil Church.new(website_url: "  ").website_url
    assert_equal "https://kirche.de", Church.new(website_url: " kirche.de ").website_url
    assert_equal "http://kirche.de/start", Church.new(website_url: "http://kirche.de/start").website_url
  end

  test "rejects invalid websites" do
    [ "kirche", "ftp://kirche.de", "https://user:pw@kirche.de", "https://kir che.de" ].each do |url|
      church = Church.new(name: "Kirche", website_url: url)
      assert_not church.valid?, "#{url} should be invalid"
      assert church.errors.include?(:website_url)
    end
  end

  test "allows embedding on the website host and its subdomains only" do
    church = Church.new(website_url: "https://www.Gemeinde-Eins.example/kontakt")

    assert_equal "gemeinde-eins.example", church.website_host
    assert church.embed_allowed_host?("gemeinde-eins.example")
    assert church.embed_allowed_host?("www.gemeinde-eins.example")
    assert church.embed_allowed_host?("jugend.gemeinde-eins.example")
    assert_not church.embed_allowed_host?("evil-gemeinde-eins.example")
    assert_not church.embed_allowed_host?("gemeinde-eins.example.evil.com")
  end

  test "allows embedding everywhere without a website" do
    church = Church.new

    assert_not church.embed_restricted?
    assert church.embed_allowed_host?("irgendwo.example")
  end
end
