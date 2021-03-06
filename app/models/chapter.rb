class Chapter < ApplicationRecord
  include Updateable
  self.primary_keys = :story_id, :number
  belongs_to :story, touch: true
  after_create :notify_fans
  before_save :space_correct
  # after_save :split
  after_destroy_commit :update_counts

  validates :body, length: { in: 20..900000,
    too_short: "must be at least %{count} characters long",
    too_long: "must be at most %{count} characters long" }

  def notify_fans
    unless (number == 1)
      story.user.fans.each do |fan|
        UserMailMailer.chapter_added(fan, self).deliver_now
      end
    end
  end

  def space_correct
    body.gsub!('&nbsp;', ' ')
  end

  def get_title
    self.title.to_s
  end

  def chapter_title
    get_title
  end

  def chapter_title=(new_title)
    self.title = new_title
  end

  def tags
    # story.tags
    ''
  end

  # todo: does this work if the story's being newly created?
  def tags=(tag_string)
    # tag_array = tag_string.split(/,\s*/)
    # story.add_tags(tag_array)
    story.set_tag_string(tag_string)
  end

  def heading
    answer = "Chapter #{number}"
    answer += ": #{title}" unless title.empty?
    answer
  end

  def update_counts
    index = number + 1
    while chap = story.get_chapter(index)
      # chap = story.get_chapter(index)
      chap.number = index - 1
      chap.save
      index += 1
    end
  end

  def to_param
    number.to_s
  end

  def self.name_field
    :title
  end
end
