class AddScheduleToLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :links, :schedule, :string, null: false, default: "always"
    add_column :links, :visible_from, :datetime
    add_column :links, :visible_until, :datetime
    add_column :links, :weekdays, :json, null: false, default: []
    add_column :links, :start_time, :string
    add_column :links, :end_time, :string
  end
end
