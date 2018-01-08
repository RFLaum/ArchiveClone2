class UsersController < ApplicationController
  include ApplicationHelper
  before_action :set_user #, only: %i[show destroy send_confirmation]
  skip_before_action :set_user, only: %i[
    register index create logout login faves subs forgot
  ]
  before_action :check_user, only: %i[deactivate edit update]

  def register
    @page_title = "Register new user"
    @user = User.new
  end

  def login
    @page_title = "Log In"
  end

  def index
    @page_title = "Users"
    @users = is_admin? ? User.all : User.where(is_confirmed: true)
    @users = @users.order(name: :asc).paginate(page: params[:page])
  end

  def show
    @page_title = @user.name
    @viewer = current_user_or_guest
    @stories = @user.visible_stories(@viewer)
                    .order(updated_at: :desc)
                    .paginate(page: params[:page], per_page: 10)
  end

  def edit
    @page_title = "Editing #{@user.name}"
  end

  def update
    pars = params_for_edit

    if pars[:password].size + pars[:password_confirmation].size > 0
      unless @user.authenticate(pars[:old_password])
        @error_message = 'Incorrect password'
      end
    end

    if defined? @error_message
      render :edit #, locals: {error_message: error_message}
    else
      pars.delete(:old_password)
      if @user.update(pars)
        redirect_to @user
      else
        render :edit
      end
    end
  end

  def create
    @user = User.new(params_for_create)
    # if @user.invalid?
    #   render('errors/generic_error', locals: {message: @user.errors.inspect}) && return
    # end
    # if BannedAddress.is_banned?(@user.email)
    #   render('errors/generic_error',
    #          locals: { message: "That email is banned." }) && return
    # end
    @user.confirmation_hash = generate_hash
    if @user.save
      if BannedAddress.is_banned?(@user.email)
        render('errors/generic_error',
               locals: { message: "That email is banned." }) && return
      else
        send_confirmation
      end
      # redirect_to action: index
      # render 'signup_made'
    else
      @page_title = "Sign Up"
      render 'register'
    end
  end

  def send_confirmation
    UserMailMailer.registration_confirm(@user).deliver_now
    #have to do this because sometimes this method is called from create
    render 'send_confirmation'
  end

  def confirm
    @message = ""
    begin
      # @user = User.find(params[:user_name])
      # logger.debug "is_confirmed datatype: #{@user.is_confirmed.class}"
      # if @user.is_confirmed
      #   message = "Error: user #{@user.name} already active."
      # elsif @user.confirmation_hash != params[:hash]
      #   message = "Error: invalid confirmation hash."
      if @user.confirmation_hash != params[:hash]
        @message = "Error: invalid confirmation hash."
      elsif @user.is_confirmed
        render 'reset_password'
        # redirect_to action: 'forgot'  && return
      else
        @message = "User account #{@user.name} activated!"
        @user.is_confirmed = true
        @message = "Could not save" unless @user.save
        login_internal
      end
    rescue ActiveRecord::RecordNotFound
      @message = "Error: no such user."
    end
    # render :confirm, locals: { message: message }
  end

  def login_receiver
    # @user = User.find(params[:user_name])
    if !@user
      @error_message = 'Invalid username'
      render :login #, locals: { error_message: 'Invalid username' }
    elsif !@user.authenticate(params[:password])
      @error_message = 'Invalid password'
      render :login #, locals: { error_message: 'Invalid password' }
    elsif !@user.is_confirmed
      render "not_confirmed"
    elsif @user.deactivated
      render "deactivated"
    else
      login_internal
      redirect_override(@user)
    end
  end

  def logout
    @page_title = "Logged Out"
    session[:user] = nil
  end

  def destroy
    if is_correct_user?(@user)
      unregister
    # elsif is_admin?
      # ban_internal
    else
      # wrong_user(@user, true)
      wrong_user(@user)
    end
  end

  def ban
    check_admin
    ban_internal
  end

  def deactivate
    # if is_correct_user?(@user)
    @user.deactivated = true
    @user.save
    redirect_to action: 'index'
    # else
    #   wrong_user(@user)
    # end
  end

  def faves
    anon_cant(faves_path) && return unless logged_in?
    @user = current_user
    @page_title = "#{@user}'s Favorite Tags"
  end

  def subscribe
    if cu = current_user
      fvs = cu.fave_writers
      unless fvs.include?(@user)
        fvs << @user
      end
    end
    redirect_to session[:return_page]
  end

  def unsubscribe
    if cu = current_user
      fvs = cu.fave_writers
      if fvs.include?(@user)
        fvs.delete(@user)
      end
    end
    redirect_to session[:return_page]
  end

  def subs
    @page_title = "Subscriptions"
    anon_cant(subs_path) && return unless logged_in?
  end

  def forgot
    @page_title = "Forgot Password"
  end

  def forgot_receiver
    @page_title = "Forgot Password"
    if @user.deactivated
      render 'errors/generic_error',
      locals: {message: "Error: Account of user '#{@user.name}' has been deactivated."}
    elsif !@user.is_confirmed
      render 'errors/generic_error',
      locals: {message: "Error: This email address has not yet been confirmed."}
    else
      @user.confirmation_hash = generate_hash
      @user.save
      UserMailMailer.forgot(@user).deliver_now
    end
  end

  def reset_receiver
    unless params[:conf] == @user.confirmation_hash
      redirect_to action: 'confirm'
    end
    if @user.update(params_for_edit)
      redirect_to login_path, notice: "Password updated"
    else
      render action: 'confirm'
    end

  end

  private

  def ban_internal
    @user_name = @user.name
    BannedAddress.add_email(@user.email)
    UserMailMailer.ban_notification(@user).deliver_now
    # @user.destroy
    # User.where(admin: false).find_each do |usr|
    #   if BannedAddress.is_banned?(usr.email)
    # end
    BannedAddress.destroy_users_matching(@user.email)
    render :banned
  end

  def unregister
    @user_name = @user.name
    UserMailMailer.unregistration(@user).deliver_now
    # logger.debug "Stories of user #{@user.name}: #{@user.stories.size}"
    @user.destroy
    render :unregistered
  end

  def login_internal
    session.delete(:adult)
    session[:user] = @user.name
  end

  def set_user
    #do this as find_by rather than find in order to better handle the case
    #where an incorrect username is submitted
    # @user = User.find_by(name: params[:id])
    @user = User.find_by_name(params[:id])
    unless @user
      # @username = params[:id]
      @username = User.un_param(params[:id])
      render 'errors/no_such_user'
    end
    # @was_set_user_called = true
  end

  def check_user
    super(@user)
  end

  def params_for_create
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end

  def params_for_edit
    params.require(:user).permit(:adult, :avatar, :password, :delete_avatar,
                                 :password_confirmation, :old_password,
                                 :time_zone)
  end
end
