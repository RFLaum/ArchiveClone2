class JoinUsersTags2 < ActiveRecord::Migration[5.0]
  def change
    # create_join_table :users, :tags, table_name: :fave_tags

    # add_index :fave_tags, %i[user_name tag_id], unique: true

    create_table :fave_tags, id: false do |t|
      t.string :user_name
      t.string :tag_name
    end
    add_index :fave_tags, %i[user_name tag_name], unique: true
  end
end
