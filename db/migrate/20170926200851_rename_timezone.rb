class RenameTimezone < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :timezone, :time_zone
  end
end
