class Bookmark < ApplicationRecord
  include Updateable
  belongs_to :user, foreign_key: 'user_name', primary_key: 'name'
  belongs_to :story
end
