class CreateForms < ActiveRecord::Migration[8.1]
  def change
    create_table :forms do |t|
      t.references :church, null: false, foreign_key: true
      t.string :title, null: false
      t.text :intro
      t.text :thank_you_message
      t.string :submit_label
      t.string :notification_emails
      t.text :consent_text
      t.string :privacy_url
      t.integer :retention_months

      t.timestamps
    end
  end
end
