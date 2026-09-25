class CreateChurches < ActiveRecord::Migration[8.1]
  def change
    create_table :churches do |t|
      t.string :name, null: false
      t.string :slug, null: false

      t.timestamps
    end
    add_index :churches, :slug, unique: true
  end
end
