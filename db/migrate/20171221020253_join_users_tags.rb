class JoinUsersTags < ActiveRecord::Migration[5.0]
  def up
    execute "ALTER TABLE users ADD PRIMARY KEY (name)"
  end

  def down
    execute "ALTER TABLE users DROP PRIMARY KEY"
  end
end
