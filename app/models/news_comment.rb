class NewsComment < ApplicationRecord
  include Updateable

  belongs_to :user, foreign_key: 'author', primary_key: 'name'
  belongs_to :newspost 
end
