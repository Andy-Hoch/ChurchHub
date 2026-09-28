class Church < ApplicationRecord
  SLUG_FORMAT = /[a-z0-9]+(?:-[a-z0-9]+)*/
  # Top-level paths used by the app itself; a church with such a slug could
  # never be reached under /<slug>.
  RESERVED_SLUGS = %w[
    session sessions passwords registration account hub church churches church_switch embed up forms
    admin api assets rails cable manifest service-worker icon robots favicon
  ].freeze

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_one :hub, dependent: :destroy
  has_many :forms, dependent: :destroy

  normalizes :slug, with: ->(slug) { slug.to_s.parameterize }
  normalizes :website_url, with: ->(url) do
    url = url.strip
    url.match?(%r{\Ahttps?://}i) ? url : "https://#{url}" if url.present?
  end

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A#{SLUG_FORMAT}\z/ }, exclusion: { in: RESERVED_SLUGS }
  validate :website_url_must_be_valid

  before_validation :generate_slug, on: :create
  after_create :create_default_hub

  # Host the launcher is restricted to, without a leading "www." so that
  # the bare domain, www and every other subdomain are allowed alike.
  def website_host
    website_uri&.host&.downcase&.delete_prefix("www.")
  end

  def embed_restricted?
    website_host.present?
  end

  def embed_allowed_host?(host)
    return true unless embed_restricted?

    host = host.to_s.downcase
    host == website_host || host.end_with?(".#{website_host}")
  end

  private
    def website_uri
      URI.parse(website_url) if website_url.present?
    rescue URI::InvalidURIError
      nil
    end

    def website_url_must_be_valid
      return if website_url.blank?

      uri = website_uri
      valid = uri.is_a?(URI::HTTP) && uri.userinfo.nil? && uri.host.present? &&
        (uri.host.include?(".") || uri.host == "localhost")
      errors.add(:website_url, "ist keine gültige Webseiten-Adresse") unless valid
    end

    def generate_slug
      return if slug.present? || name.blank?

      base = name.parameterize.presence || "kirche"
      candidate = base
      counter = 1
      while Church.exists?(slug: candidate) || RESERVED_SLUGS.include?(candidate)
        counter += 1
        candidate = "#{base}-#{counter}"
      end
      self.slug = candidate
    end

    def create_default_hub
      create_hub!(title: name)
    end
end
