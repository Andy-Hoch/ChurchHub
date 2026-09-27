class CreateLinks < ActiveRecord::Migration[8.1]
  def change
    create_table :links do |t|
      t.references :hub, null: false, foreign_key: true
      t.string :title, null: false
      t.string :url, null: false
      t.string :description
      t.string :icon
      t.integer :position, null: false, default: 0
      t.boolean :visible, null: false, default: true

      t.timestamps
    end
    add_index :links, [ :hub_id, :position ]
  end
end
