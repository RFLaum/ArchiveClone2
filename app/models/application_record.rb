class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  #returns true if added, false if not added
  def add_unless_present(col, obj)
    already_in = col.include?(obj)
    col << obj unless already_in
    !already_in
  end

  #primary key for join tables
  def self.pfj
    "#{table_name}.#{primary_key}"
  end

  #get value of primary key
  def prim_val
    self[self.class.primary_key]
  end
end
