class NewspostsController < ApplicationController
  before_action :check_admin
  before_action :set_newspost, only: %i[show edit update destroy]
  skip_before_action :check_admin, only: %i[index show]

  # GET /newsposts
  # GET /newsposts.json
  def index
    # redirect_to news_tag_newsposts_path(params[:tag]) if params[:tag]
    # @newsposts = Newspost.all
    @page_title = 'Newsposts'
    # if params[:tag]
    @newsposts = Newspost.all
    if tag_id = params[:news_tag_id] || params[:tag]
      # @tag = NewsTag.find_by_name(params[:tag])
      @tag = NewsTag.find_by(id: tag_id)
      if @tag
        @newsposts = @tag.newsposts
        @page_title += " tagged with \"#{@tag.name}\""
      end
    # else
    #   @newsposts = Newspost.all
    end
    @newsposts = @newsposts.order(created_at: :desc)
    @page_posts = @newsposts.paginate(page: params[:page])
    # page_num = params[:page] || 1
    # @newsposts = @newsposts.order(created_at: :desc).paginate(page: page_num)
  end

  # GET /newsposts/1
  # GET /newsposts/1.json
  def show
    @page_title = @newspost.title
    @prev_post = Newspost.where('id < ?', @newspost.id).last
    @next_post = Newspost.where('id > ?', @newspost.id).first
  end

  # GET /newsposts/new
  def new
    @newspost = Newspost.new
  end

  # GET /newsposts/1/edit
  def edit
    # if is_admin?
    #   @newspost = Newspost.find(params[:id])
    #   render 'edit'
    # else
    #   non_admin_cant(request.fullpath)
    # end
  end

  # POST /newsposts
  # POST /newsposts.json
  def create
    # render 'errors/not_admin' && return unless is_admin?
    @newspost = Newspost.new(newspost_params)
    @newspost.admin = current_user.name

    respond_to do |format|
      if @newspost.save
        format.html { redirect_to @newspost, notice: 'Newspost was successfully created.' }
        format.json { render :show, status: :created, location: @newspost }
      else
        format.html { render :new }
        format.json { render json: @newspost.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /newsposts/1
  # PATCH/PUT /newsposts/1.json
  def update
    respond_to do |format|
      if @newspost.update(newspost_params)
        format.html { redirect_to @newspost, notice: 'Newspost was successfully updated.' }
        format.json { render :show, status: :ok, location: @newspost }
      else
        format.html { render :edit }
        format.json { render json: @newspost.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /newsposts/1
  # DELETE /newsposts/1.json
  def destroy
    @newspost.destroy
    respond_to do |format|
      format.html { redirect_to newsposts_url, notice: 'Newspost was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
  def set_newspost
    @newspost = Newspost.find(params[:id])
  end

  def newspost_params
    params.require(:newspost).permit(:admin_name, :title, :content, :tags_public)
  end
end
