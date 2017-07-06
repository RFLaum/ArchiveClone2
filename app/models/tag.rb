class Tag < ApplicationRecord
  has_and_belongs_to_many :stories

  #translates a user-input tag to the form used by the database
  #todo
  def self.tr_to_sql(dirty)
    dirty
  end

end
