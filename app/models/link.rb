class Link < ApplicationRecord
  belongs_to :hub, touch: true

  normalizes :url, with: ->(url) { url.strip }

  validates :title, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 160 }
  validates :icon, length: { maximum: 8 }
  validate :url_must_be_http

  before_create :append_to_end

  scope :visible, -> { where(visible: true) }

  def move_to(new_position)
    siblings = hub.links.where.not(id: id).to_a
    siblings.insert(new_position.to_i.clamp(0, siblings.size), self)

    transaction do
      siblings.each_with_index do |link, index|
        link.update_column(:position, index) unless link.position == index
      end
      hub.touch
    end
  end

  def embed_payload
    { title: title, url: url, description: description.presence, icon: icon.presence }
  end

  private
    def url_must_be_http
      uri = URI.parse(url.to_s)
      errors.add(:url, :invalid) unless uri.is_a?(URI::HTTP) && uri.host.present?
    rescue URI::InvalidURIError
      errors.add(:url, :invalid)
    end

    def append_to_end
      self.position = (hub.links.maximum(:position) || -1) + 1
    end
end
