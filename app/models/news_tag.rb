class NewsTag < ApplicationRecord
  include Impliable
  # self.primary_key = :name
  has_and_belongs_to_many :newsposts

  has_many :implieds, class_name: 'NewsImplication', foreign_key: 'implier_id'
  has_many :implied_tags, through: :implieds, source: :gen_tag

  has_many :impliers, class_name: 'NewsImplication', foreign_key: 'implied_id'
  has_many :implying_tags, through: :impliers, source: :spec_tag

  before_destroy :knit_implications

  #translates a user-input tag to the form used by the database
  #todo
  def self.tr_to_sql(dirty)
    dirty.downcase
  end

  def tagged_objs
    newsposts
  end
end
