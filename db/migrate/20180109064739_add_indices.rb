class AddIndices < ActiveRecord::Migration[5.0]
  def change
    add_index :tags, :adult
    add_index :stories, :adult_override
    add_index :stories_tags, :name
    add_index :stories_tags, :story_id
  end
end
