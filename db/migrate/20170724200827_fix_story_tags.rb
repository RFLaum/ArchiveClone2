class FixStoryTags < ActiveRecord::Migration[5.0]
  def change
    change_table :stories_tags do |t|
      t.remove :tag_id
      t.column :tag, :string
    end
  end
end
