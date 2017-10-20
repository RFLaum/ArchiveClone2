class AddStoryCounts < ActiveRecord::Migration[5.0]
  def change
    add_column :sources, :stories_count, :integer, default: 0, null: false
    add_index :sources, :stories_count
    add_column :characters, :stories_count, :integer, default: 0, null: false
    add_index :characters, :stories_count
  end
end
