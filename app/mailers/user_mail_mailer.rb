class UserMailMailer < ApplicationMailer
  helper :users

  def registration_confirm(user)
    @user = user
    mail(to: @user.email, subject: "Confirm your registration")
  end
end
