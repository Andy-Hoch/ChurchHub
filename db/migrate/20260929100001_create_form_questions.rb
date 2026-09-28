class CreateFormQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :form_questions do |t|
      t.references :form, null: false, foreign_key: true
      t.string :kind, null: false, default: "short_text"
      t.string :label, null: false
      t.string :help_text
      t.boolean :required, null: false, default: false
      t.json :choices, null: false, default: []
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :form_questions, [ :form_id, :position ]
  end
end
