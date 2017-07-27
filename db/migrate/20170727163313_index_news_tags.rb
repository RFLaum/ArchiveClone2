class IndexNewsTags < ActiveRecord::Migration[5.0]
  def change
    add_index :news_tags, :name, unique: true
  end
end
