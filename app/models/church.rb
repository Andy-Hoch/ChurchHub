class Church < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_one :hub, dependent: :destroy

  normalizes :slug, with: ->(slug) { slug.to_s.parameterize }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create
  after_create :create_default_hub

  private
    def generate_slug
      return if slug.present? || name.blank?

      base = name.parameterize.presence || "kirche"
      candidate = base
      counter = 1
      while Church.exists?(slug: candidate)
        counter += 1
        candidate = "#{base}-#{counter}"
      end
      self.slug = candidate
    end

    def create_default_hub
      create_hub!(title: name)
    end
end
