class Hub < ApplicationRecord
  POSITIONS = %w[right left].freeze
  COLOR_SCHEMES = %w[light dark auto].freeze
  BUTTON_ICONS = %w[grid menu heart cross link].freeze
  FONT_FAMILIES = {
    "sans" => %("Source Sans 3", system-ui, -apple-system, "Segoe UI", sans-serif),
    "serif" => %("Source Serif 4", Georgia, "Times New Roman", serif)
  }.freeze

  belongs_to :church
  has_many :links, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :hub

  has_secure_token :public_token

  normalizes :primary_color, :text_color, with: ->(color) { OklchColor.normalize(color) || color.strip }

  validates :title, presence: true, length: { maximum: 80 }
  validates :button_label, length: { maximum: 30 }
  validates :primary_color, :text_color, format: { with: OklchColor::FORMAT }
  validates :position, inclusion: { in: POSITIONS }
  validates :color_scheme, inclusion: { in: COLOR_SCHEMES }
  validates :button_icon, inclusion: { in: BUTTON_ICONS }
  validates :font_family, inclusion: { in: FONT_FAMILIES.keys }
  validates :corner_radius, numericality: { only_integer: true, in: 0..24 }

  def theme
    {
      primaryColor: primary_color,
      textColor: text_color,
      position: position,
      buttonLabel: button_label,
      buttonIcon: button_icon,
      colorScheme: color_scheme,
      cornerRadius: corner_radius,
      fontFamily: font_family
    }
  end

  # The native color picker only understands hex.
  def primary_color_hex = OklchColor.to_hex(primary_color)
  def text_color_hex = OklchColor.to_hex(text_color)

  def embed_payload
    {
      title: title,
      theme: theme,
      links: links.select(&:embeddable?).map(&:embed_payload)
    }
  end
end
