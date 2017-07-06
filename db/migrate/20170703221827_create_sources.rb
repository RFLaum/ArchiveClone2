class CreateSources < ActiveRecord::Migration[5.0]
  def change
    create_table :sources do |t|
      t.string :name
      t.boolean :book
      t.boolean :celeb
      t.boolean :music
      t.boolean :theater
      t.boolean :video_games
      t.boolean :anime
      t.boolean :comics
      t.boolean :movies
      t.boolean :misc
      t.boolean :tv

      t.timestamps
    end
  end
end
