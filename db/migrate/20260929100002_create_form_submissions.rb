class CreateFormSubmissions < ActiveRecord::Migration[8.1]
  def change
    create_table :form_submissions do |t|
      t.references :form, null: false, foreign_key: true, index: false
      t.json :answers, null: false, default: []
      t.datetime :read_at

      t.timestamps
    end
    add_index :form_submissions, [ :form_id, :created_at ]
  end
end
