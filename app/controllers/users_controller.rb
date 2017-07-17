class UsersController < ApplicationController
  include ApplicationHelper
  # rescue_from ActiveRecord::RecordNotFound with: user_not_found

  def register
    @user = User.new
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    # @stories = @user.stories
  end

  def create
    @user = User.new(params.require(:user).permit(:name, :email, :password,
                                                  :password_confirmation))
    @user.confirmation_hash = generate_hash
    if @user.save
      UserMailMailer.registration_confirm(@user).deliver_now
      # redirect_to action: index
      render 'signup_made'
    else
      @title = "Sign Up"
      render 'register'
    end
  end

  def confirm
    message = ""
    begin
      @user = User.find(params[:user_name])
      logger.debug "is_confirmed datatype: #{@user.is_confirmed.class}"
      if @user.is_confirmed
        message = "Error: user #{@user.name} already active."
      elsif @user.confirmation_hash != params[:hash]
        message = "Error: invalid confirmation hash."
      else
        message = "User account #{@user.name} activated!"
        @user.is_confirmed = true
        @user.save
        login_internal
      end
    rescue ActiveRecord::RecordNotFound
      message = "Error: no such user."
    end
    render :user_confirm, locals: { message: message }
  end

  def login_receiver
    # message = ''
    # @user = User.find(params[:user][:name])
    # logger.debug "login_receiver"
    # params.each do |k,v|
    #   logger.debug "#{k}\t#{v}"
    # end
    @user = User.find(params[:user_name])
    if !@user
      # message = 'Invalid Username'
      render :login, locals: { error_message: 'Invalid username' }
    # elsif @user.password == params[:user][:password]
    # elsif @user.password == params[:password]
    elsif @user.authenticate(params[:password])
      login_internal
      # render :show
      # redirect_to @user
      redirect_override(@user)
    else
      render :login, locals: { error_message: 'Invalid password' }
    end
  end

  def logout
    session[:user] = nil
  end

  private

  # def generate_hash

  def login_internal
    session[:user] = @user.name
  end

  def try_login(user_name, password)
    @user = User.find(user_name)
    unless user
      redirect_to login_page, notice: "Incorrect username"
    end
    if @user.password == password
      login_internal
      redirect_to @user
    else
      redirect_to login_page, notice: "Incorrect password"
    end
  end
end
