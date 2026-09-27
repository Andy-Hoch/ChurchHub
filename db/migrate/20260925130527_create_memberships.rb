class CreateMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :church, null: false, foreign_key: true
      t.string :role, null: false, default: "admin"

      t.timestamps
    end
    add_index :memberships, [ :user_id, :church_id ], unique: true
  end
end
