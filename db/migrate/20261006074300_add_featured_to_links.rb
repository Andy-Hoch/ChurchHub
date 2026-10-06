class AddFeaturedToLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :links, :featured, :boolean, null: false, default: false
  end
end
