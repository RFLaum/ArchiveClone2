# class SearchController < ApplicationController
class SearchController < SuperSearchController
  def full_form; end

  def results
    search_class = params[:type].constantize
    results = search_class.search(params[:q]).records
    # @results = @results.paginate(page: params[:page])
    # render 'results'
    result_display(results)
  end

  # def result_display(results)
  #   @results = results.paginate(page: params[:page])
  #   render 'results'
  # end
end
