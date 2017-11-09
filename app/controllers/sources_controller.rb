# class SourcesController < ApplicationController
class SourcesController < SuperSearchController
  before_action :set_source, only: %i[show edit update destroy]
  # skip_before_action :set_source, only: %i[search_results search_form index new
  #                                          create index_type update_form
  #                                          update_receiver]
  def search_results
    @page_title = 'Source Search Results'
    pars = params.permit(:name, types: [])
    type_arr = pars[:types] ? pars[:types].map(&:to_sym) : nil
    results = Source.search(pars[:name], type_arr).records
    # @results = @results.paginate(page: params[:page])
    # render 'search/results'
    result_display(results)
  end

  def search_form
    @page_title = 'Source Search'
  end

  #todo
  def show
    @page_title = @source.name
  end

  def index
    @page_title = 'All Source Media'
    # if params[:type].present?
    #   type_sym = params[:type].to_sym
    #   if Source.source_types.include? type_sym
    #     @sources = Source.where(type_sym => true)
    #     @page_title += ': ' + Source.source_plurals[type_sym].titleize
    #   end
    # end
    # @sources = Source.all unless defined? @sources
    # @sources = Source.all.paginate(page: params[:page])
    @sources = Source.all.order(:name).paginate(page: params[:page])
  end

  def index_type
    type_sym = params[:type].to_sym
    redirect_to sources_path unless Source.source_types.include? type_sym
    @sources = Source.where(type_sym => true)
                     .order(:name)
                     .group_by{ |src| src.name[0].upcase }
                    #  .paginate(page: params[:page])
    @page_title = Source.source_plurals[type_sym].titleize
  end

  def new
    @page_title = "New Source Media"
    @source = Source.new
  end

  def create
    @source = Source.new(source_params)
    @source.save
    redirect_to @source
  end

  def edit
    @page_title = "Editing #{@source.name}"
  end

  def update
    @source.update(source_params)
    redirect_to @source
  end

  def destroy
    @source.destroy
    redirect_to sources_url
  end

  def update_form
    @page_title = 'Bulk Update Sources'
    @sources = Source.all
    render 'bulk_update'
  end

  def update_receiver
    @page_title = 'Update results'
    # render 'update_results'
    params.permit!
    Source.bulk_update(params[:source])
    @sources = Source.all
    render 'bulk_update'
  end

  private

  def source_params
    #TODO: make sure this works for setting and removing types
    params.require(:source).permit(:name, Source.source_types, :chars_public)
  end

  def set_source
    @source = Source.find(params[:id])
  end
end
