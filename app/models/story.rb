class Story < ApplicationRecord
  # has_and_belongs_to_many :sources
  has_and_belongs_to_many :tags, association_foreign_key: 'name'
  has_many :chapters, dependent: :destroy
  belongs_to :user, foreign_key: 'author', primary_key: 'name' #, dependent: :destroy

  after_save :save_dummy
  # after_initialize :make_dummy

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

  def tags_public
    tags.map(&:name).join(", ")
  end

  def tags_public=(new_tags_string)
    add_tags(new_tags_string.split(/,\s*/))
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
end
