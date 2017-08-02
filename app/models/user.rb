class User < ApplicationRecord
  self.primary_key = :name
  has_many :stories, foreign_key: 'author', primary_key: 'name', dependent: :destroy
  has_many :comments, foreign_key: 'author', primary_key: 'name', dependent: :destroy

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
  validates :password, length: { minimum: 8 }

  def story_permissions(story)
    # answer = { read: false, edit: false, delete: false }
    if story.user == self
      # answer[:read] = answer[:edit] = answer[:delete] = true
      # return answer
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

end
