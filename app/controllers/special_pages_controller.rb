class SpecialPagesController < ApplicationController
  def home
    @page_title = "Home"
  end

  def home2
    @page_title = 'Home'
    @latest_news = Newspost.order(created_at: :desc).limit(3)
  end

  def about
    @page_title = 'About AOC'
  end

end
