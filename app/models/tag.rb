require 'elasticsearch/model'

class Tag < ApplicationRecord
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  self.primary_key = :name
  has_and_belongs_to_many :stories, foreign_key: 'name'

  #translates a user-input tag to the form used by the database
  #todo
  def self.tr_to_sql(dirty)
    dirty
  end

  def self.search(query)
    # __elasticsearch__.search query: { wildcard: { name: query } }
    __elasticsearch__.search query: {
      query_string: {
        default_field: 'name',
        default_operator: 'AND',
        query: query
      }
    }
  end

end

# Tag.import
# Tag.__elasticsearch__.create_index! force: true
