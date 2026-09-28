class Link < ApplicationRecord
  include Positionable

  belongs_to :hub, touch: true
  belongs_to :form, optional: true

  enum :kind, { link: "link", form: "form" }, prefix: true, validate: true

  positioned_within :hub, :links

  normalizes :url, with: ->(url) { url.strip.presence }

  validates :title, presence: true, length: { maximum: 80 }
  validates :description, length: { maximum: 160 }
  validates :icon, length: { maximum: 8 }
  validate :url_must_be_http, if: :kind_link?
  validate :form_must_belong_to_church, if: :kind_form?

  before_save :clear_unused_target

  scope :visible, -> { where(visible: true) }

  # Form buttons whose form was deleted stay in the list but are not shown.
  def embeddable?
    visible? && (kind_link? || form.present?)
  end

  def embed_payload
    payload = { title: title, description: description.presence, icon: icon.presence }

    if kind_form?
      payload.merge(type: "form", form: form.embed_payload)
    else
      payload.merge(type: "link", url: url)
    end
  end

  private
    def url_must_be_http
      errors.add(:url, :invalid) unless HttpUrl.valid?(url)
    end

    def form_must_belong_to_church
      if form.nil?
        errors.add(:form, :blank)
      elsif form.church_id != hub&.church_id
        errors.add(:form, :invalid)
      end
    end

    def clear_unused_target
      if kind_form?
        self.url = nil
      else
        self.form = nil
      end
    end
end
