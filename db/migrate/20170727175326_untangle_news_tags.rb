class UntangleNewsTags < ActiveRecord::Migration[5.0]
  def change
    drop_table :news_tags_newsposts

    create_join_table :newsposts, :news_tags do |t|
      t.index :newspost_id
      t.index :news_tag_id
      # t.index [:newspost_id, :news_tag_id]
      # t.index [:news_tag_id, :newspost_id]
    end
  end
end
