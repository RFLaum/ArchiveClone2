module Storycount
  extend ActiveSupport::Concern
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  module ClassMethods

    def search(query)
      # logger.debug "storycount search"
      # __elasticsearch__.search query: { wildcard: { name: query } }
      __elasticsearch__.search(
        sort: [
          { stories_count: { order: 'desc' } }
        ],
        query: {
          query_string: {
            default_field: 'name',
            default_operator: 'AND',
            query: query
          }
        }
      )
    end

    def reset_stories_count
      find_each do |obj|
        obj.update_attributes(stories_count: obj.stories.size)
      end
    end

  end
end
