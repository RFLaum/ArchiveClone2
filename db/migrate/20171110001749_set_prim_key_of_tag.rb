class SetPrimKeyOfTag < ActiveRecord::Migration[5.0]
  def up
    execute "ALTER TABLE tags ADD PRIMARY KEY (name)"
  end

  def down
    execute "ALTER TABLE chapters DROP PRIMARY KEY"
  end
end
