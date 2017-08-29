# require 'elasticsearch/model'
# require 'elasticsearch/dsl'

class Story < ApplicationRecord
  include Taggable
  include Searchable
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks
  # has_and_belongs_to_many :sources
  has_and_belongs_to_many :tags, association_foreign_key: 'name'
  has_many :chapters, dependent: :destroy
  has_many :comments, dependent: :destroy
  belongs_to :user, foreign_key: 'author', primary_key: 'name' #, dependent: :destroy

  after_save :save_dummy

  def num_chapters
    chapters.size
  end

  def add_tags(new_tags)
    new_tags.each do |tag|
      tag = Tag.tr_to_sql(tag)
      tags << Tag.find_or_initialize_by(name: tag) unless tags.exists?(name: tag)
    end
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

  # def initialize(*params)
    # super(params)
  # def make_dummy
  #   logger.debug "entered make_dummy"
  #   @dummy_chapter = Chapter.new(story_id: self.id, number: 1,
  #                                title: '', body: '')
  # end

  def dummy
    # if @dummy_chapter.nil?
    #   @dummy_chapter = Chapter.new(story_id: id, number: 1, title: '', body: '')
    # end
    # @dummy_chapter
    @dummy_chapter ||= Chapter.new(story_id: id, number: 1, title: '', body: '')
  end

  def first_chapter
    # return @dummy_chapter if chapters.empty?
    # get_chapter(1)
    # return get_chapter(1) unless chapters.empty?
    # chapters.empty? ? @dummy_chapter : get_chapter(1)
    # logger.debug "entered first_chapter"
    # logger.debug "dummy class: #{@dummy_chapter.class}"
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
        query = query.left_outer_joins(:comments) #.distinct
        # query = query.select('stories.*, COUNT(comments.*) AS com_count')
        # query = query.group('stories.id').order('com_count')
        query = query.select('stories.*, COUNT(comments.*)')
        query = query.group('stories.id') #.order('COUNT(comments.*)')
        order_clause = 'COUNT(comments.*)'
        # logger.debug "sort_query: #{query.to_sql}"
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

  private

  def get_tags
    tags
  end

  def tag_class
    Tag
  end
end


# Story.__elasticsearch__.create_index! force: true
# Story.import
