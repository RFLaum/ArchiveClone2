require 'elasticsearch/model'

class Source < ApplicationRecord
  include Updateable
  include Storycount
  # include Impliable
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  has_many :characters, after_add: :update_stories
  has_and_belongs_to_many :stories

  SOURCE_TYPES = %i[
    book celeb music theater video_games anime comics movies misc tv
  ].freeze

  #TODO: test
  before_save do
    unless SOURCE_TYPES.map { |type| self[type] }.any?
      self.misc = true
    end
  end

  def update_stories(char)
    char.stories.each do |story|
      story.add_source(self)
    end
  end

  #probably better to handle pluralization with Rails's built-in i18n
  SOURCE_PLURALS = {
    book: 'books',
    celeb: 'celebrities',
    music: 'music',
    theater: 'theater',
    video_games: 'video games',
    anime: 'manga/anime',
    comics: 'western comics',
    movies: 'movies',
    misc: 'miscellaneous',
    tv: 'television'
  }.freeze

  SOURCE_SINGULAR = {
    book: 'book',
    celeb: 'celebrity',
    music: 'music',
    theater: 'theater',
    video_games: 'video game',
    anime: 'manga/anime',
    comics: 'western comic',
    movies: 'movie',
    misc: 'miscellaneous',
    tv: 'television'
  }.freeze

  def self.source_types
    SOURCE_TYPES
  end

  def self.source_plurals
    SOURCE_PLURALS
  end

  def self.source_singulars
    SOURCE_SINGULAR
  end

  #types should be an array of symbols, not strings
  def self.search(query, types = nil)
    # __elasticsearch__.search query: { wildcard: { name: query } }
    types = SOURCE_TYPES.dup unless types
    should_term = []
    types.each do |type|
      should_term << { term: { type => true } }
    end

    __elasticsearch__.search(
      query: {
        bool: {
          must: [
            query_string: {
              default_field: 'name',
              default_operator: 'AND',
              query: query
            }
          ],
          should: should_term,
          minimum_should_match: 1
        }
      }
    )
  end

  def implied_tags
    []
  end

  def self.tr_to_sql(dirty)
    # dirty.downcase
    dirty
  end

  def chars_public
    # characters.reduce { |str, char| str + ', ' + char.name }
    characters.map(&:name).join(', ')
  end

  def chars_public=(new_chars)
    characters.clear
    new_chars.split(/,\s*/).each do |char|
      characters << Character.find_or_initialize_by(name: char)
    end
  end

  def display_name
    name
  end

  def self.name_field
    :name
  end

  def type_list_key
    SOURCE_TYPES.select { |type| self[type] }
  end

  def type_list_sing
    SOURCE_SINGULAR.values_at(*type_list_key)
  end

  def type_list_plur
    SOURCE_PLURALS.values_at(*type_list_key)
  end

  def types=(type_arr)
    type_syms = type_arr.map(&:to_sym)
    SOURCE_TYPES.each do |type|
      self[type] = type_syms.include?(type)
    end
  end

  #new_data is a hash; key is id of source as a string, value is new data for
  #that source
  def self.bulk_update(new_data)
    new_data.each do |k, v|
      find(k.to_i).update(v)
    end
  end

  # def get_descendant_implications
  #   []
  # end
end
