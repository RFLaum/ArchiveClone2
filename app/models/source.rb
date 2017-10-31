require 'elasticsearch/model'

class Source < ApplicationRecord
  include Updateable
  include Storycount
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
    characters.reduce { |str, char| str + ', ' + char.name }
  end

  def chars_public=(new_chars)
    new_chars.split(/,\s+/).each do |char|
      characters << Character.find_or_initialize_by(name: char)
    end
  end

  def display_name
    name
  end
end
