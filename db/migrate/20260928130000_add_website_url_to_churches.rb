class AddWebsiteUrlToChurches < ActiveRecord::Migration[8.1]
  def change
    add_column :churches, :website_url, :string
  end
end
