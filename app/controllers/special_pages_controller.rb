class SpecialPagesController < ApplicationController
  def home
    # Tag.reset_stories_count
    @page_title = "Home"
  end
end
