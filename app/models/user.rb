require 'elasticsearch/model'

class User < ApplicationRecord
  include Updateable
  include Nameclean
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  self.primary_key = :name
  has_many :stories,   foreign_key: 'author', primary_key: 'name',
                       dependent: :destroy, after_add: :mail_followers
  has_many :comments,  foreign_key: 'author', primary_key: 'name',
                       dependent: :destroy
  has_many :newsposts, foreign_key: 'admin', primary_key: 'name',
                       dependent: :destroy
  has_many :bookmarks, foreign_key: 'user_name', primary_key: 'name',
                       dependent: :destroy
  has_many :faves, through: :bookmarks, source: :story
  has_many :news_comments, foreign_key: 'author', primary_key: 'name',
                           dependent: :destroy
  has_and_belongs_to_many :tags, join_table: :fave_tags, primary_key: 'name',
                                 foreign_key: 'user_name',
                                 association_foreign_key: 'tag_name'

  has_many :sub_reads, class_name: 'Subscription', foreign_key: 'reader_name',
                       primary_key: 'name'
  has_many :sub_writes, class_name: 'Subscription', foreign_key: 'writer_name',
                        primary_key: 'name'
  has_many :fave_writers, through: :sub_reads, source: :writer
  has_many :fans, through: :sub_writes, source: :reader

  before_save { self.email = email.downcase }
  validates :name,
            presence: { message: " can't be blank." },
            length: { maximum: 50, message: "Name is too long." },
            exclusion: { in: ['guest'] },
            # format: { with: /[^\/]+/,
            #           message: " cannot contain the character '/'" },
            uniqueness: true
  EMAIL_REGEX = /\A[\w+\-\.\+]+@[a-z\d\-\.]+\.[a-z]+\z/i
  validates :email, presence: true,
                    format: { with: EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  # validates :password, length: { minimum: 8 }
  has_attached_file :avatar,
                    styles: { original: "100x100>" },
                    default_url: "avatars/default_avatar.jpg"

  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/
  validates_attachment_size :avatar, less_than: 200.kilobytes

  def self.find_by_name(str)
    # super(un_param(str))
    find_by(name: un_param(str))
  end

  def delete_avatar=(del)
    self.avatar = nil if del.to_i == 1
  end

  def delete_avatar
    false
  end

  def mail_followers(story)
    self.fans.each do |fan|
      UserMailMailer.story_created(self, fan, story).deliver_now
    end
  end

  def story_permissions(story)
    if story.user == self
      return { read: true, edit: true, delete: true }
    end
    if self.admin
      return { read: true, edit: false, delete: true }
    end
    answer = { read: true, edit: false, delete: false }
    #todo: handle this correctly when session[:adult] is true
    if story.is_adult? && !self.adult
      answer[:read] = false
    end
    answer
  end

  def can_post?
    self.is_confirmed && !(self.deactivated)
  end

  def visible_stories(other_user)
    get_all = (other_user == self) || other_user.adult
    get_all ? stories : Story.non_adult(stories)
  end

  def visible_bookmarks(other_user)
    other_user == self ? bookmarks : bookmarks.where(private: false)
  end

  def to_partial_path
    'users/summary'
  end

  # def num_bookmarks(can_see_private)
  #   can_see_private ? bookmarks.count : bookmarks.where(private: false).count
  # end

  def self.valid_user?(username)
    return false unless self.exists?(username)
    self.find(username).can_post?
  end

  def self.find_email_by_regex(re_str)
    self.where("email ~* ?", re_str)
  end

  def self.search(query)
    __elasticsearch__.search query: {
      query_string: {
        default_field: 'name',
        default_operator: 'AND',
        query: query
      }
    }
  end

  def get_zone
    ActiveSupport::TimeZone.new(time_zone)
  end

  #paramater is a TimeWithZone
  def time_to_local(twz)
    twz.in_time_zone(get_zone)
  end

  def display_name
    name
  end

  def self.name_field
    :name
  end

end

# User.__elasticsearch__.create_index! force: true
# User.import
