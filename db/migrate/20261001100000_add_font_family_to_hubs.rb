class AddFontFamilyToHubs < ActiveRecord::Migration[8.1]
  def change
    add_column :hubs, :font_family, :string, null: false, default: "sans"
  end
end
