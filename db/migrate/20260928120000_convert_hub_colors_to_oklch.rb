class ConvertHubColorsToOklch < ActiveRecord::Migration[8.1]
  class MigrationHub < ActiveRecord::Base
    self.table_name = "hubs"
  end

  COLUMNS = { primary_color: "#18181b", text_color: "#ffffff" }.freeze

  def up
    COLUMNS.each do |column, default|
      change_column_default :hubs, column, from: default, to: OklchColor.normalize(default)
    end

    convert { |color| OklchColor.normalize(color) }
  end

  def down
    COLUMNS.each do |column, default|
      change_column_default :hubs, column, from: OklchColor.normalize(default), to: default
    end

    convert { |color| OklchColor.to_hex(color) }
  end

  private
    def convert
      MigrationHub.reset_column_information
      MigrationHub.find_each do |hub|
        colors = COLUMNS.keys.to_h { |column| [ column, yield(hub[column]) || hub[column] ] }
        hub.update_columns(colors)
      end
    end
end
