class RemoveIconFromLinks < ActiveRecord::Migration[8.1]
  def change
    remove_column :links, :icon, :string
  end
end
