# Manual ordering for records that admins sort by drag and drop.
# `positioned_within :hub, :links` means: siblings are `hub.links`, and the
# hub is touched after reordering so cached embeds pick up the new order.
module Positionable
  extend ActiveSupport::Concern

  class_methods do
    def positioned_within(parent, collection)
      define_method(:position_parent) { public_send(parent) }
      define_method(:position_siblings) { position_parent.public_send(collection) }

      before_create :append_to_end
    end
  end

  def move_to(new_position)
    siblings = position_siblings.where.not(id: id).to_a
    siblings.insert(new_position.to_i.clamp(0, siblings.size), self)

    transaction do
      siblings.each_with_index do |record, index|
        record.update_column(:position, index) unless record.position == index
      end
      position_parent.touch
    end
  end

  private
    def append_to_end
      self.position = (position_siblings.maximum(:position) || -1) + 1
    end
end
