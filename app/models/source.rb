class Source < ApplicationRecord
  has_many :characters
  has_and_belongs_to_many :stories
end
