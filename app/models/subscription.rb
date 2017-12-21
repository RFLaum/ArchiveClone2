class Subscription < ApplicationRecord
  belongs_to :reader, class_name: 'User', foreign_key: 'reader_name',
                      primary_key: 'name'
  belongs_to :writer, class_name: 'User', foreign_key: 'writer_name',
                      primary_key: 'name'
end
