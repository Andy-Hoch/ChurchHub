class Church < ApplicationRecord
  SLUG_FORMAT = /[a-z0-9]+(?:-[a-z0-9]+)*/
  # Top-level paths used by the app itself; a church with such a slug could
  # never be reached under /<slug>.
  RESERVED_SLUGS = %w[
    session sessions passwords registration account hub church churches church_switch embed up
    admin api assets rails cable manifest service-worker icon robots favicon
  ].freeze

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_one :hub, dependent: :destroy

  normalizes :slug, with: ->(slug) { slug.to_s.parameterize }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
    format: { with: /\A#{SLUG_FORMAT}\z/ }, exclusion: { in: RESERVED_SLUGS }

  before_validation :generate_slug, on: :create
  after_create :create_default_hub

  private
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
