class CompleteRebuild < ActiveRecord::Migration[5.0]
  def change
    drop_table :banned_addresses
    drop_table :chapters
    drop_table :characters
    drop_table :news_tags
    drop_table :newsposts
    drop_table :sources
    drop_table :stories
    drop_table :stories_tags
    drop_table :story_tags
    drop_table :tags
    drop_table :users

    create_table :banned_addresses, id: false do |t|
      t.string :email, null: false

      t.timestamps

      t.index :email, unique: true
    end

    create_table :chapters, primary_key: ["story_id", "number"] do |t|
      t.integer :story_id, null: false
      t.integer :number, null: false
      t.string :title
      t.text :body, null: false

      t.timestamps
    end

    create_table :characters do |t|
      t.integer :source_id
      t.string :name, null: false

      t.timestamps
    end

    create_table :news_tags do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :newsposts do |t|
      t.string :admin, null: false
      t.string :title
      t.text :content, null: false

      t.timestamps
    end

    create_table :sources do |t|
      t.string :name, null: false
      t.boolean :book, default: false
      t.boolean :celeb, default: false
      t.boolean :music, default: false
      t.boolean :theater, default: false
      t.boolean :video_games, default: false
      t.boolean :anime, default: false
      t.boolean :comics, default: false
      t.boolean :movies, default: false
      t.boolean :misc, default: false
      t.boolean :tv, default: false

      t.timestamps
    end

    create_table :stories do |t|
      t.string :title, null: false
      t.string :author, null: false
      t.text :summary
      t.boolean :adult_override, default: false

      t.timestamps
    end

    create_table :tags, id: false do |t|
      t.string :name, null: false
      t.boolean :adult, default: false

      t.timestamps

      t.index :name, unique: true
    end

    create_table :users, id: false do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest
      t.string :confirmation_hash
      t.boolean :is_confirmed, default: false
      t.boolean :adult, default: false
      t.boolean :admin, default: false

      t.timestamps

      t.index :name, unique: true
    end

    create_join_table :stories, :tags

    add_index :chapters, :story_id
    add_foreign_key :chapters, :stories

    add_index :characters, :source_id
    add_foreign_key :characters, :sources

    add_index :newsposts, :admin
    add_foreign_key :newsposts, :users, column: :admin, primary_key: :name

    add_index :stories, :author
    add_foreign_key :stories, :users, column: :author, primary_key: :name
  end
end
