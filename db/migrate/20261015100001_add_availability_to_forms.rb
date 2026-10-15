class AddAvailabilityToForms < ActiveRecord::Migration[8.1]
  def change
    add_column :forms, :opens_at, :datetime
    add_column :forms, :closes_at, :datetime
    add_column :forms, :submission_limit, :integer
    add_column :forms, :when_full, :string, null: false, default: "hide"
    add_column :forms, :full_message, :text
  end
end
