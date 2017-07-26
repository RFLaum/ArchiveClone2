class AddStoryIdToChapters < ActiveRecord::Migration[5.0]
  def change
    add_column :chapters, :story_id, :integer
  end
end
