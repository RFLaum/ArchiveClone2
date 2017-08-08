class NewspostsController < ApplicationController
  before_action :check_admin
  before_action :set_newspost, only: %i[show edit update destroy]
  skip_before_action :check_admin, only: %i[index show]

  # GET /newsposts
  # GET /newsposts.json
  def index
    # @newsposts = Newspost.all
    if params[:tag]
      @tag = NewsTag.find_by_name(params[:tag])
      @newsposts = @tag.newsposts if @tag
    else
      @newsposts = Newspost.all
    end
    @newsposts = @newsposts.order(created_at: :desc).paginate(page: params[:page])
  end

  # GET /newsposts/1
  # GET /newsposts/1.json
  def show
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
