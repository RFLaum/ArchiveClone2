class Character < ApplicationRecord
  include Updateable
  include Storycount
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :source #, after_add: :update_stories
  has_and_belongs_to_many :stories

  # def update_stories(source)
  #   stories.each do |story|
  #     story.add_source(source)
  #   end
  # end
  def self.tr_to_sql(dirty)
    dirty
  end

  def implied_tags
    source ? [source] : []
  end

  def display_name
    name
  end

  def source_name
    source ? source.display_name : ''
  end

  def source_name=(src_name)
    self.source = Source.find_or_initialize_by(name: src_name)
  end

  def self.name_field
    :name
  end
end


# Character.__elasticsearch__.create_index! force: true
# Character.import
