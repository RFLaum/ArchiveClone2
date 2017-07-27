class FixNewsTagsJoin < ActiveRecord::Migration[5.0]
  def change
    change_table :news_tags_newsposts do |t|
      t.remove :news_tag_id
    end
  end
end
