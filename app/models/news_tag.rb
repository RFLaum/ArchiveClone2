class NewsTag < ApplicationRecord
  has_and_belongs_to_many :newsposts
end
