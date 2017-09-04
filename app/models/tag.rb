require 'elasticsearch/model'
# require 'set'

class Tag < ApplicationRecord
  include Impliable
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  self.primary_key = :name
  has_and_belongs_to_many :stories, foreign_key: 'name'
  # has_many :implications, foreign_key: 'implier', primary_key: 'name',
  #                         dependent: :destroy
  # has_many :implications, foreign_key: 'implied', primary_key: 'name',
  #                         dependent: :destroy
  # has_many :implieds, through: :implications, class_name: 'Tag',
  has_many :implieds, class_name: 'Implication', foreign_key: 'implier',
                      primary_key: 'name'
  has_many :implied_tags, through: :implieds, source: :gen_tag

  has_many :impliers, class_name: 'Implication', foreign_key: 'implied',
                      primary_key: 'name'
  has_many :implying_tags, through: :impliers, source: :spec_tag

  before_destroy :knit_implications

  # #if A implies B implies C, then deleting B makes A imply c
  # before_destroy do
  #   implying_tags.each do |parent|
  #     before = parent.implied_tags
  #     implied_tags.each do |child|
  #       before << child unless before.exists?(name: child.name)
  #     end
  #   end
  # end

  # after_save do
  #   if self.adult
  #     implying_tags.each do |parent|
  #       parent.adult = true
  #       parent.save
  #     end
  #   end
  # end

  # def self.get_descendant_implications(children)
  #   answer = Set.new
  #   #we don't want to do this as test_tags = children, because then changing
  #   #test_tags will change descs
  #   test_tags = children.dup
  #   until test_tags.empty?
  #     tag = test_tags.pop
  #     test_tags.concat(tag.implied_tags) if answer.add?(tag)
  #   end
  #   answer
  # end

  # def get_descendant_implications
  #   Tag.get_descendant_implications(implied_tags)
  # end

  # def implications_loop?(descs = implied_tags)
  #   get_descendant_implications(descs).intersect?(implying_tags.to_set)
  # end

  #children is a collection of the new child tags
  #returns an array of children that could not be added
  # def add_implications(children)
  #   # new_descs = get_descendant_implications(imp_arr)
  #   bad_kids = []
  #   good_kids = []
  #   # parents = implying_tags.to_set
  #   children.each do |child|
  #     descs = child.get_descendant_implications
  #     if child == self || descs.include?(self) #descs.intersect?(parents)
  #       bad_kids << child.name
  #     else
  #       good_kids << child.name
  #       implied_tags << child
  #     end
  #   end
  #
  #   stories.each do |story|
  #     story.set_tags(good_kids)
  #     # logger.debug "story name: #{story.title}"
  #   end
  #   bad_kids
  # end

  # def add_imps_by_name(name_str)
  #   kids = name_str.split(/,\s*/).map do |name|
  #     Tag.find_or_initialize_by(name: Tag.tr_to_sql(name))
  #   end
  #   add_implications(kids)
  # end

  # def set_adult(new_val)
  #   self.adult = new_val
  #   if new_val
  #     implying_tags.each do |tag|
  #       tag.set_adult(new_val)
  #     end
  #   end
  # end

  # def set_adult(new_val)
  #   unless new_val
  #     if
  # end

  def tagged_objs
    stories
  end

  #translates a user-input tag to the form used by the database
  #todo
  def self.tr_to_sql(dirty)
    dirty.downcase
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
