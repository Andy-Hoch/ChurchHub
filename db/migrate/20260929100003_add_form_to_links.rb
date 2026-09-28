class AddFormToLinks < ActiveRecord::Migration[8.1]
  def change
    add_column :links, :kind, :string, null: false, default: "link"
    add_reference :links, :form, foreign_key: { on_delete: :nullify }
    change_column_null :links, :url, true
  end
end
