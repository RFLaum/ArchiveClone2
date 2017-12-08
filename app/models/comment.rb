class Comment < ApplicationRecord
  include Updateable

  belongs_to :user, foreign_key: 'author', primary_key: 'name'
  belongs_to :story

  # todo: worry about validations later
  # validates :author, presence: true


end
