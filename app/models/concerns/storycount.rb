require 'elasticsearch/model'

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

    #finds the most common tags used within a given set of stories. story_set
    #is an ActiveRecord::Relation
    def most_common(story_set, num = 10)
      joins(:stories).merge(story_set)
                     .select("#{table_name}.*, COUNT(*) AS cnt")
                     .group(pfj)
                     .reorder('cnt DESC')
                     .limit(num)
    end

    def cloud_names(num = 9)
      answer = []
      num.times do |i|
        answer << "cloud_item#{i + 1}"
      end
      answer
    end

  end
end
