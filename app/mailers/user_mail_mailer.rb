class UserMailMailer < ApplicationMailer
  helper :users
  helper :application

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

  def story_created(writer, reader, story)
    @writer = writer
    @reader = reader
    @story  = story
    subject = "#{@writer.name} has posted a new story"
    mail(to: @reader.email, subject: subject)
  end

  def chapter_added(reader, chapter)
    @story   = chapter.story
    @writer  = @story.user
    @reader  = reader
    @chapter = chapter

    subject = "#{@writer.name} has added a new chapter to #{@story.title}"
    mail(to: @reader.email, subject: subject)
  end
end
