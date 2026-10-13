class RemoveDescriptionFromLinks < ActiveRecord::Migration[8.1]
  def change
    remove_column :links, :description, :string
  end
end
