class NewPrimary < ActiveRecord::Migration[5.0]
  def up
    execute "ALTER TABLE chapters ADD PRIMARY KEY (story_id, number)"
  end

  def down
    execute "ALTER TABLE chapters DROP PRIMARY KEY"
  end
end
