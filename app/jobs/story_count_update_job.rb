class StoryCountUpdateJob < ApplicationJob
  queue_as :default

  # def perform(*args)
  #   [Tag, Source, Character].each(&:reset_stories_count)
  # end
end
