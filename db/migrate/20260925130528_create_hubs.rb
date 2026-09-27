class CreateHubs < ActiveRecord::Migration[8.1]
  def change
    create_table :hubs do |t|
      t.references :church, null: false, foreign_key: true, index: { unique: true }
      t.string :title, null: false
      t.string :public_token, null: false
      t.boolean :enabled, null: false, default: true
      t.string :primary_color, null: false, default: "#18181b"
      t.string :text_color, null: false, default: "#ffffff"
      t.string :position, null: false, default: "right"
      t.string :button_label, null: false, default: "Links"
      t.string :button_icon, null: false, default: "grid"
      t.string :color_scheme, null: false, default: "light"
      t.integer :corner_radius, null: false, default: 12

      t.timestamps
    end
    add_index :hubs, :public_token, unique: true
  end
end
