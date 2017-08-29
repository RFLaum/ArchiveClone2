class SearchController < ApplicationController
  def full_form; end

  def results
    search_class = params[:type].constantize
    @results = search_class.search(params[:q]).records
  end
end
