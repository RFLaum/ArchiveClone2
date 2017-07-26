class UserMailMailer < ApplicationMailer
  helper :users

  def registration_confirm(user)
    @user = user
    @register_path = user_url(@user) + "/auth=#{@user.confirmation_hash}"
    mail(to: @user.email, subject: "Confirm your registration")
  end

  def ban_notification(user)
    @user = user
    mail(to: @user.email, subject: "You have been banned")
  end

  def unregistration(user)
    @user = user
    mail(to: @user.email, subject: "Account deleted")
  end
end
