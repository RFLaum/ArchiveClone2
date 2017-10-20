class SuperSearchController < ApplicationController
  def result_display(results)
    @results = results.paginate(page: params[:page])
    render 'search/results'
  end
end
