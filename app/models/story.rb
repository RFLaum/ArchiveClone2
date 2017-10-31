# require 'elasticsearch/model'
# require 'elasticsearch/dsl'

class Story < ApplicationRecord
  include Updateable
  include Taggable
  include Searchable

  # validates :title, presence: true
  validates :title, length: { in: 5..80,
    too_short: "must be at least %{count} characters long",
    too_long: "must be at most %{count} characters long" }

  validates :summary, length: { in: 10..200,
    too_short: "must be at least %{count} characters long",
    too_long: "must be at most %{count} characters long" }

  validate :check_chapter_validity, on: :create
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks
  has_and_belongs_to_many :tags, association_foreign_key: 'name',
                                 after_add: %i[increment_count add_kids],
                                 after_remove: :decrement_count
  has_many :chapters, dependent: :destroy
  has_many :comments, dependent: :destroy
  belongs_to :user, foreign_key: 'author', primary_key: 'name'
  has_and_belongs_to_many :sources, after_add: :increment_count,
                                    after_remove: :decrement_count

  has_many :bookmarks, dependent: :destroy
  has_many :favers, through: :bookmarks, source: :user

  has_and_belongs_to_many :characters, after_add: %i[increment_count add_kids],
                                       after_remove: :decrement_count

  # after_save :save_dummy, on: :create
  after_create :save_dummy, :set_initial_counts
  before_destroy :decrement_counts
  after_update :add_missing_sources

  def get_prim_key; :name; end;

  def deleted_tags
    []
  end

  def check_chapter_validity
    #have to check validity first, or else the message won't be set
    #we don't want to do this with validates_associated, becaause we only want
    #to check this when creating the story, not when editing it
    if first_chapter.invalid?
      msg = first_chapter.errors.messages[:body]
      errors.add(:body, msg.join(', and ')) unless msg.empty?
    end
  end

  def set_initial_counts
    [tags, sources, characters].each do |coll|
      coll.each do |obj|
        obj.increment!(:stories_count)
      end
    end
  end

  def decrement_counts
    [tags, characters, sources].each do |arr|
      arr.each do |obj|
        obj.decrement!(:stories_count)
      end
    end
  end

  def increment_count(obj)
    obj.increment!(:stories_count) unless new_record?
  end

  def decrement_count(obj)
    # logger.debug "decrement_count #{obj.name}"
    obj.decrement!(:stories_count)
  end

  # def add_kids(obj)
  #   obj.implied_tags.each do |child|
  #   end
  # end

  def num_chapters
    chapters.size
  end

  def get_chapter(num)
    chapters.find_by(number: num)
  end

  def get_chapters
    chapters.order("number ASC")
  end

  def get_comments
    comments.order("created_at ASC")
  end

  def get_dummy_comment(author)
    comments.build(author: author)
  end

  def dummy
    @dummy_chapter ||= Chapter.new(story_id: id, number: 1, title: '', body: '')
  end

  def first_chapter
    dummy_saved? ? get_chapter(1) : dummy
  end

  def chapter_title
    first_chapter.title
  end

  def chapter_title=(new_title)
    first_chapter.title = new_title
  end

  def body
    first_chapter.body
  end

  def body=(new_body)
    first_chapter.body = new_body
  end

  def dummy_saved?
    !self.chapters.empty?
  end

  def save_dummy
    # logger.debug "entered save_dummy"
    return if dummy_saved?
    # logger.debug  "didn't return"
    # logger.debug "dummy title: #{@dummy_chapter.title}"
    self.chapters << dummy #@dummy_chapter
    # logger.debug "saved"
  end

  def is_adult?
    return true if adult_override
    return true if tags.exists?(adult: true)
    false
  end

  SORT_COLUMNS = [
    ['Author', 'author'],
    ['Title', 'title'],
    ['Date Posted', 'created_at'],
    ['Date Updated', 'updated_at'],
    ['Comments', 'num_comments']
  ].freeze

  # def self.search(query_params)
  #   # tag_array = query_params[:tags].split(/,\s*/)
  #   definition = Elasticsearch::DSL::Search.search {
  #     query do
  #       bool do
  #         if query_params[:title].present?
  #           must do
  #             query_string do
  #               query query_params[:title]
  #               default_operator 'and'
  #               fields %w[title]
  #             end
  #           end
  #         end
  #
  #         if query_params[:author].present?
  #           must do
  #             query_string do
  #               query query_params[:author]
  #               default_operator 'and'
  #               fields %w[author]
  #             end
  #           end
  #         end
  #
  #         if query_params[:tags].present?
  #           query_params[:tags].split(/,\s*/).each do |tag|
  #             must do
  #               query_string do
  #                 query tag
  #                 default_operator 'and'
  #               end
  #             end
  #           end
  #         end
  #
  #       end
  #     end
  #   }
  #   answer = __elasticsearch__.search(definition).records
  #   answer = answer.reject(&:is_adult?) if query_params[:show_adult].blank?
  #   answer = answer.select(&:is_adult?) if query_params[:show_non_adult].blank?
  #   answer
  # end

  def self.search(query_params)
    query = where('true')
    %i[title author].each do |par|
      if query_params[par].present?
        query = convert_query(query_params[par], 'stories.' + par.to_s, query)
      end
    end
    %i[updated created].each do |par|
      if query_params[par].present?
        date_range = convert_time(query_params[par])
        col_name = "stories.#{par}_at"
        if date_range[:min].present?
          query = query.where(col_name + ' >= ?', date_range[:min])
        end
        if date_range[:max].present?
          query = query.where(col_name + ' <= ?', date_range[:max])
        end
      end
    end
    if query_params[:tags].present?
      query_params[:tags].split(/,\s*/).each do |tag|
        cond = select('1').from('stories_tags')
        cond = cond.where('stories_tags.story_id = stories.id')
        cond = convert_query(tag, 'stories_tags.name', cond, true)
        query = query.where("EXISTS (#{cond.to_sql})")
      end
    end
    if query_params[:sort_by].present?
      order_clause = query_params[:sort_by]
      if order_clause == 'num_comments'
        query = query.left_outer_joins(:comments)
        query = query.select('stories.*, COUNT(comments.*)')
        query = query.group('stories.id')
        order_clause = 'COUNT(comments.*)'
      end
      query = query.order(order_clause + ' ' + query_params[:sort_direction])
    end
    if query_params[:show_adult].blank?
      query = query.reject(&:is_adult?)
    end
    if query_params[:show_non_adult].blank?
      #because the parameter is a proc, this calls enumerable's select, not
      #ActiveRecord::Relation's select
      query = query.select(&:is_adult?)
    end
    query
  end

  def sources_public
    tags_public(:source)
  end

  def sources_public=(new_string)
    # tags_public= new_string, :source
    tags_public_internal(new_string, :source)
  end

  def chars_public
    tags_public(:character)
  end

  def chars_public=(new_chars)
    tags_public_internal(new_chars, :character)
  end

  def add_character(char)
    add_source(char.source) if add_unless_present(characters, char)
  end

  def add_source(src)
    add_unless_present(sources, src)
  end

  def maybe_remove_source(src)
    unless characters.exists?(source_id: src.id)
      sources.delete(src)
    end
  end

  def deleted_characters=(chars_to_delete)
    delete_only(chars_to_delete, characters, :id)
  end

  def deleted_sources=(srcs_to_delete)
    # srcs = sources.find(srcs_to_delete)
    # srcs.each do |src|
    #   maybe_remove_source(src)
    # end
    delete_only(srcs_to_delete, sources, :id)
  end

  def deleted_tags=(tags_to_delete)
    delete_only(tags_to_delete, tags, :name)
  end

  def add_missing_sources
    add_missing_imps(characters, :source)
    add_missing_imps(tags, :tag)
  end

  def srcs_add=(srcs_string)
    set_tag_string(srcs_string, false, :source)
  end

  def srcs_add; ''; end

  def tags_add=(tags_string)
    set_tag_string(tags_string, false, :tag)
  end

  def tags_add; ''; end

  def chars_add=(chars_string)
    set_tag_string(chars_string, false, :character)
  end

  def chars_add; ''; end

  def display_name
    title
  end

  private

  def get_tags(type = nil)
    type ||= :tag
    case type
    when :tag
      tags
    when :source
      sources
    when :character
      characters
    end
  end

  def tag_class(type = nil)
    type ||= :tag
    case type
    when :tag
      Tag
    when :source
      Source
    when :character
      Character
    end
  end

  # def add_obj(obj)
  #   case obj.class
  #   when Tag
  #     tags << obj
  #   when Source
  #     sources << obj
  #   when
  # end
end


# Story.__elasticsearch__.create_index! force: true
# Story.import
