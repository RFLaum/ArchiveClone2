class User < ApplicationRecord
  self.primary_key = :name
  has_many :stories, foreign_key: 'author', primary_key: 'name', dependent: :destroy
  has_many :comments, foreign_key: 'author', primary_key: 'name', dependent: :destroy
  has_many :newsposts, foreign_key: 'admin', primary_key: 'name', dependent: :destroy

  before_save { self.email = email.downcase }
  validates :name,
            presence: { message: " can't be blank." },
            length: { maximum: 50, message: "Name is too long." },
            exclusion: { in: ['guest'] },
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

  def delete_avatar=(del)
    self.avatar = nil if del.to_i == 1
  end

  def delete_avatar
    false
  end

  def story_permissions(story)
    if story.user == self
      return { read: true, edit: true, delete: true }
    end
    if self.admin
      return { read: true, edit: false, delete: true }
    end
    answer = { read: true, edit: false, delete: false }
    if story.is_adult? && !self.adult
      answer[:read] = false
    end
    answer
  end

  def can_post?
    self.is_confirmed && !(self.deactivated)
  end

  def self.valid_user?(username)
    return false unless self.exists?(username)
    self.find(username).can_post?
  end

  def self.find_email_by_regex(re_str)
    self.where("email ~* ?", re_str)
  end

end
