require 'elasticsearch/model'

module Storycount
  extend ActiveSupport::Concern
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  def visible_stories(reader)
    return stories if reader.adult
    Story.non_adult(stories).or(stories.where(user: reader))
  end

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
      rflct = reflect_on_association(:stories)
      join_table = rflct.join_table
      join_sql = "INNER JOIN #{join_table} AS jt ON " +
                 "jt.#{rflct.foreign_key} = " +
                 "answer.#{primary_key}"
      processed_set = story_set.where("stories.id = jt.#{rflct.association_foreign_key}")

      self.select('answer.*, COUNT(*) as cnt')
          .from("#{table_name} AS answer")
          .joins(join_sql)
          .where("EXISTS (#{processed_set.to_sql})")
          .group("answer.#{primary_key}")
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

    def get_top(base_set = all, num = 100)
      base_rel = base_set.order(stories_count: :desc).limit(num)
      min = base_rel.last.stories_count
      max = base_rel.first.stories_count
      alpha_rel = select('*').from("(#{base_rel.to_sql}) as alias")
                             .order("alias.#{name_field} ASC")
      [alpha_rel, min, max]
    end

    # def get_top_ordered(base_set = all, num = 100)
    #   select('*').from("(#{get_top(base_set, num).to_sql})").where(true)
    #              .order(name_field: :asc)
    # end

  end
end
