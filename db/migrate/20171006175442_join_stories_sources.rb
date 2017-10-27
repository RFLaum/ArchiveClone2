class JoinStoriesSources < ActiveRecord::Migration[5.0]
  def change
    create_join_table :sources, :stories do |t|
      t.index :story_id
      t.index :source_id
    end
  end
end
