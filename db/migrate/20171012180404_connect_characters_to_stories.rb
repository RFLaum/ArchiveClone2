class ConnectCharactersToStories < ActiveRecord::Migration[5.0]
  def change
    create_join_table :characters, :stories do |t|
      t.index :character_id
      t.index :story_id
    end
  end
end
