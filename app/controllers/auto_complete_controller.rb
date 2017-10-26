class AutoCompleteController < ApplicationController

  def tag
    # res = Tag.search(params[:q]).paginate(page: 1, per_page: 10)

    answer = Tag.search(params[:q] + '*').records.limit(10).select('name')
    hldr = answer.map(&:attributes)
    #need to do this to properly prevent duplicates from being selected
    #because tag doesn't have an id attribute
    hldr.each do |h|
      h['id'] = h['name']
    end
    render json: hldr
    # respond_to do |format|
    #   format.html
    #   format.json { render json: hldr }
    # end
  end

  def source
    search_general(Source, params[:q])
  end

  def character
    search_general(Character, params[:q])
  end

  private

  def search_general(klass, query)
    answer = klass.search(query + '*').records.limit(10).select('name, id')
    render json: answer
  end
end
