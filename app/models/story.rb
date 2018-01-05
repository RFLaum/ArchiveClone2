# require 'elasticsearch/model'
# require 'elasticsearch/dsl'

class Story < ApplicationRecord
  include Updateable
  include Taggable
  include Searchable
  include Commentable
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks

  # validates :title, presence: true
  validates :title, length: { in: 5..80,
    too_short: "must be at least %{count} characters long",
    too_long: "must be at most %{count} characters long" }

  validates :summary, length: { in: 10..3000,
    too_short: "must be at least %{count} characters long",
    too_long: "must be at most %{count} characters long" }

  validate :check_chapter_validity, on: :create
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks
  has_and_belongs_to_many :tags, association_foreign_key: 'name',
                                 after_add: %i[increment_count add_kids],
                                 after_remove: :decrement_count
  has_many :chapters, dependent: :destroy #, after_add: :fans_chapter
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

  #gets primary key of Tag; NOT primary key of Story
  def get_prim_key; :name; end;

  def deleted_tags; []; end
  def deleted_sources; []; end
  def deleted_characters; []; end

  def check_chapter_validity
    #have to check validity first, or else the message won't be set
    #we don't want to do this with validates_associated, becaause we only want
    #to check this when creating the story, not when editing it
    if first_chapter.invalid?
      msg = first_chapter.errors.messages[:body]
      errors.add(:body, msg.join(', and ')) unless msg.empty?
    end
  end

  def to_partial_path
    'stories/summary'
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

  # def fans_chapter(chapter)
  #   unless chapter.number == 1
  #     self.user.fans.each do |fan|
  #       UserMailMailer.chapter_added(fan, chapter).deliver_now
  #     end
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

  # def delete_chapter(num)
  #   nc = num_chapters
  #   return if num > nc
  #   get_chapter(num).destroy
  #   (num..nc).each do |i|
  #     chap = get_chapter(i)
  #     chap.number = i - 1
  #     chap.save
  #   end
  # end

  def visible_bookmarks(viewing_user)
    Bookmark.visible_filter(bookmarks, viewing_user)
  end

  # def get_comments
  #   comments.order("created_at ASC")
  # end

  # def get_dummy_comment(author)
  #   comments.build(author: author)
  # end

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

  def comment_edit_helper
    :edit_story_comment_path
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

  def insert_chapters(chap_arr, pos)
    # result = true
    return false if chap_arr.any?(&:invalid?)

    nc = num_chapters
    n_add = chap_arr.size

    pos = [pos, nc + 1].min

    (pos..nc).reverse_each do |i|
      if chap = get_chapter(i)
        chap.number += n_add
        chap.save
      end
    end

    chap_arr.each_with_index do |chap, i|
      chap.story = self
      chap.number = i + pos
      chap.save
    end
    true
  end

  def split(body, pos)
    doc = Nokogiri::HTML.parse(body)
    headings = doc.css('.chaptertitle')
    chap_arr = []
    base_this = "//*[not(@class='chaptertitle')]" +
                "[not(@class='chapterhead')]" +
                "[not(self::hr)]" +
                "[not(self::h2[child::a])]"

    base_cntr = "[count(preceding-sibling::p[@class='chaptertitle']) = %d]"
    # logger.debug "split test"
    headings.count.times do |i|
      selector = base_this + (base_cntr % (i + 1))
      # logger.debug "split selector"
      # logger.debug selector
      node_set = doc.xpath(selector)
      # chap = Chapter.new(number: number + i, title: headings[i], body: node_set.to_s)
      chap_arr << Chapter.new(title: headings[i].text, body: node_set.to_html)
    end
    insert_chapters(chap_arr, pos)
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

  # def self.convert_elastic(field_name, query)
  #   logger.debug "convert_elastic a"
  #   answer = __elasticsearch__.search(
  #     query: {
  #       query_string: {
  #         default_field: field_name,
  #         default_operator: 'AND',
  #         query: query
  #       }
  #     }
  #   ).records
  #   logger.debug "convert_elastic b"
  #   logger.debug answer.class.to_s
  #   answer
  # end

  def self.search(query_params)
    query = where('true')
    %i[title author].each do |par|
      if query_params[par].present?
        query = convert_query(query_params[par], 'stories.' + par.to_s, query)
        # query = query.merge(convert_elastic(par.to_s, query_params[par]))
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
    # if query_params[:tags].present?
    #   query_params[:tags].split(/,\s*/).each do |tag|
    #     cond = select('1').from('stories_tags')
    #     cond = cond.where('stories_tags.story_id = stories.id')
    #     cond = convert_query(tag, 'stories_tags.name', cond, true)
    #     query = query.where("EXISTS (#{cond.to_sql})")
    #   end
    # end
    # [Tag, Source, Character].each do |klass|
    #   sym = (klass.to_s + 's').downcase.to_sym
    #   if query_params[sym].present?
    #     rflct = reflect_on_association(sym)
    #     tab_name = rflct.join_table
    #     key = rflct.association_foreign_key
    #     query_params[sym].split(/,\s*/).each do |obj|
    #       cond = select('1').from(tab_name)
    #       cond = cond.where("#{tab_name}.#{rflct.foreign_key} = stories.id")
    #       cond = convert_query(obj, "#{tab_name}.#{key}", cond, true)
    #       query = query.where("EXISTS (#{cond.to_sql})")
    #     end
    #   end
    # end
    # query = tsc_search(query, query_params)
    query = tsc_wrapper(query, query_params, false)
    # if query_params[:sort_by].present?
    #   order_clause = query_params[:sort_by]
    #   if order_clause == 'num_comments'
    #     query = query.left_outer_joins(:comments)
    #     query = query.select('stories.*, COUNT(comments.*)')
    #     query = query.group('stories.id')
    #     order_clause = 'COUNT(comments.*)'
    #   end
    #   query = query.order(order_clause + ' ' + query_params[:sort_direction])
    # end
    query = s_sort(query, query_params[:sort_by], query_params[:sort_direction])
    if query_params[:show_adult].blank?
      # query = query.reject(&:is_adult?)
      query = non_adult(query)
    end
    if query_params[:show_non_adult].blank?
      #because the parameter is a proc, this calls enumerable's select, not
      #ActiveRecord::Relation's select
      # query = query.select(&:is_adult?)
      query = only_adult(query)
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

  def self.name_field
    :title
  end

  def self.get_key_of(tag_sym)
    tag_sym == :tags ? 'name' : 'id'
  end

  #story_set is sql query to merge this into; s_hash is hash of search terms,
  #with keys :tags, :sources, :characters
  def self.tsc_search(story_set, s_hash)
    %i[tags sources characters].each do |k|
      next unless v = s_hash[k]
      # logger.debug "tsc test #{k}"
      # logger.debug v
      rflct = reflect_on_association(k)
      table_name = rflct.join_table
      story_key = rflct.foreign_key
      tag_key = rflct.association_foreign_key
      v = v.split(/,\s*/) if v.is_a?(String)
      v.each do |query|
        cond = select('1').from(table_name)
        cond = cond.where("#{table_name}.#{story_key} = stories.id")
        cond = convert_query(query, "#{table_name}.#{tag_key}", cond, true)
        story_set = story_set.where("EXISTS (#{cond.to_sql})")
      end
    end
    story_set
  end

  #exact is a boolean indicating whether this is an exact match on primary key;
  #if it's false, we do a fuzzy search instead
  #s_hash is a hash with :tags, :sources, :characters as the keys and the
  #search query for that type of object as the values
  def self.tsc_wrapper(story_set, s_hash, exact)
    %i[tags sources characters].each do |k|
      next unless v = s_hash[k]
      if exact
        story_set = exact_search(story_set, k, v)
      else
        #for tags, sources, and characters, the field is always called 'name'
        story_set = approx_search(story_set, k, v, 'name')
      end
    end
    story_set
  end

  def self.approx_search(story_set, assoc_sym, queries, field)
    queries = queries.split(/,\s*/) if queries.is_a?(String)
    rflct = reflect_on_association(assoc_sym)
    table_name = rflct.join_table
    story_key = rflct.foreign_key
    tag_key = rflct.association_foreign_key
    klass = rflct.klass
    queries.each do |query|
      base_join = "#{table_name} INNER JOIN #{klass.table_name} ON "
      base_join += "#{table_name}.#{tag_key} = #{klass.pfj}"
      cond = select('1').from(base_join)
      cond = cond.where("#{table_name}.#{story_key} = stories.id")
      cond = convert_query(query, "#{klass.table_name}.#{field}", cond, false)
      # cond = convert_query(query, "#{table_name}.#{tag_key}", cond, true)
      story_set = story_set.where("EXISTS (#{cond.to_sql})")
    end
    logger.debug "approx_search #{assoc_sym}"
    logger.debug "sql: #{story_set.to_sql}"
    story_set
  end

  def self.exact_search(story_set, assoc_sym, vals)
    vals = vals.split(/,\s*/) if vals.is_a?(String)
    rflct = reflect_on_association(assoc_sym)
    table_name = rflct.join_table
    story_key = rflct.foreign_key
    tag_key = rflct.association_foreign_key
    vals.each do |val|
      cond = select('1').from(table_name)
      cond = cond.where("#{table_name}.#{story_key} = stories.id")
      cond = cond.where("#{table_name}.#{tag_key} = ?", val)
      story_set = story_set.where("EXISTS (#{cond.to_sql})")
    end
    story_set
  end

  def self.s_sort(story_set, sort_by, sort_dir)
    # logger.debug "s_sort #{sort_by}"
    # logger.debug "s_sort #{sort_dir}"
    sort_by = (sort_by || :updated_at).to_sym
    sort_dir = (sort_dir || :desc).to_sym
    # logger.debug "s_sort #{sort_by}"
    # logger.debug "s_sort #{sort_dir}"
    if sort_by == :num_comments
      return story_set.left_outer_joins(:comments)
                      .select('stories.*, COUNT(comments.*)')
                      .group('stories.id')
                      .order("COUNT(comments.*) #{sort_dir}")
    end
    story_set.order(sort_by => sort_dir)
  end

  #TODO: test this
  def self.only_adult(story_set)
    answer = story_set.left_outer_joins(:tags).distinct
    answer.where("stories.adult_override = true OR tags.adult = true")
  end

  #TODO: test this
  def self.non_adult(story_set)
    answer = story_set.where(adult_override: false)
    cond = "SELECT 1 FROM stories_tags INNER JOIN tags ON stories_tags.name "
    cond += " = tags.name WHERE tags.adult = 't' AND stories_tags.story_id "
    cond += " = stories.id"
    answer.where.not("EXISTS (#{cond})")
  end

  #TODO: test
  def self.visible_filter(story_set, viewing_user)
    return story_set if viewing_user.adult
    first = non_adult(story_set)
    second = story_set.where(user: viewing_user)
    first.or(second)
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
