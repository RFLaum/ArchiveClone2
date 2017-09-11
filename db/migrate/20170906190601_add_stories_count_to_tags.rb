class AddStoriesCountToTags < ActiveRecord::Migration[5.0]
  def change
    add_column :tags, :stories_count, :integer, default: 0, null: false
    add_index :tags, :stories_count
  end
end
