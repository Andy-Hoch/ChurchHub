class Church < ApplicationRecord
  SLUG_FORMAT = /[a-z0-9]+(?:-[a-z0-9]+)*/
  # Top-level paths used by the app itself; a church with such a slug could
  # never be reached under /<slug>. Files in public/ count too, because they
  # are also served without their extension (/404 serves public/404.html).
  RESERVED_SLUGS = (%w[
    session sessions passwords registration account hub church churches church_switch embed up forms
    admin api assets rails cable manifest service-worker icon robots favicon csp-reports
  ] + Dir.children(Rails.public_path).map { |file| File.basename(file, ".*") }).uniq.freeze

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_one :hub, dependent: :destroy
  has_many :forms, dependent: :destroy

  normalizes :slug, with: ->(slug) { slug.to_s.parameterize }
  normalizes :website_url, with: ->(url) do
    url = url.strip
    url.match?(%r{\Ahttps?://}i) ? url : "https://#{url}" if url.present?
  end
  normalizes :privacy_url, with: ->(value) { value.strip.presence }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A#{SLUG_FORMAT}\z/ }, exclusion: { in: RESERVED_SLUGS }
  validates :consent_text, length: { maximum: 1000 }
  validate :website_url_must_be_valid
  validate :privacy_url_must_be_http

  before_validation :generate_slug, on: :create
  after_create :create_default_hub
  # The embed script, which carries the privacy settings, is cached by the hub's timestamp.
  after_update :touch_hub, if: -> { saved_change_to_consent_text? || saved_change_to_privacy_url? }

  # Saves the church together with the user's owner membership, so a church
  # is never left without anyone who can manage it.
  def save_with_owner(user)
    transaction do
      save && memberships.create!(user: user, role: :owner)
    end.present?
  end

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

  # Every form asks for consent when the church has a consent text.
  def consent_required?
    consent_text.present?
  end

  def privacy_payload
    { consentText: consent_text.presence, privacyUrl: privacy_url.presence }
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
      errors.add(:website_url, :invalid_website) unless valid
    end

    def privacy_url_must_be_http
      errors.add(:privacy_url, :invalid) if privacy_url.present? && !HttpUrl.valid?(privacy_url)
    end

    def touch_hub
      hub.touch if hub&.persisted?
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
