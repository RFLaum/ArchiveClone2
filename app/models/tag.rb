require 'elasticsearch/model'
# require 'set'

class Tag < ApplicationRecord
  include Updateable
  include Impliable
  include Storycount
  include Nameclean
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  self.primary_key = :name
  has_and_belongs_to_many :stories, foreign_key: 'name'
  # has_many :aliases, class_name: 'Tag', foreign_key: 'aliased_to'
  # belongs_to :base_tag, class_name: 'Tag'

  has_many :implieds, class_name: 'Implication', foreign_key: 'implier',
                      primary_key: 'name' #, dependent: :destroy
  has_many :implied_tags, through: :implieds, source: :gen_tag, after_add: :update_one_adult

  has_many :impliers, class_name: 'Implication', foreign_key: 'implied',
                      primary_key: 'name' #, dependent: :destroy
  has_many :implying_tags, through: :impliers, source: :spec_tag

  has_and_belongs_to_many :users, join_table: :fave_tags, primary_key: 'name',
                                  foreign_key: 'tag_name',
                                  association_foreign_key: 'user_name'

  after_save :update_desc_adult

  before_destroy :ki_wrapper #:knit_implications

  def update_desc_adult
    if adult
      implied_tags.each do |kid|
        kid.update(adult: true)
      end
    end
  end

  def update_one_adult(kid)
    kid.update(adult: true) if adult
  end

  def ki_wrapper
    knit_implications
    implieds.delete_all
    impliers.delete_all
  end

  def self.find_by_name(str)
    # super(un_param(str))
    find_by(name: un_param(str))
  end

  def tagged_objs
    stories
  end

  # def visible_stories(adult)
  #   adult ? stories : Story.non_adult(stories)
  # end

  def to_partial_path
    'tags/summary'
  end

  # def story_count
  #   if can_see_adult?
  #     return stories.size
  #   else
  #     return stories.count { |s| !s.is_adult? }
  #   end
  # end

  #translates a user-input tag to the form used by the database
  #todo
  def self.tr_to_sql(dirty)
    dirty.downcase
  end

  def display_name
    name
  end

  def self.name_field
    :name
  end

end

# Tag.import
# Tag.__elasticsearch__.create_index! force: true
