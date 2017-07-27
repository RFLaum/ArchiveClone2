class CreateJoinTableNewspostNewsTag < ActiveRecord::Migration[5.0]
  def change
    create_join_table :newsposts, :news_tags do |t|
      t.string :name, null: false
      t.index :name
      t.index :newspost_id
      # t.index [:newspost_id, :news_tag_id]
      # t.index [:news_tag_id, :newspost_id]
    end
    # change_table :newsposts_news_tags do |t|
    #   t.remove :news_tag_id
    # end
  end
end
