class User < ApplicationRecord
  has_many :stories, foreign_key: 'author', primary_key: 'name'

  self.primary_key = :name
  before_save { self.email = email.downcase }
  validates :name,
            presence: { message: " can't be blank." },
            length: { maximum: 50, message: "Name is too long." }
  EMAIL_REGEX = /\A[\w+\-\.\+]+@[a-z\d\-\.]+\.[a-z]+\z/i
  validates :email, presence: true,
                    format: { with: EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  validates :password, length: { minimum: 8 }

end
