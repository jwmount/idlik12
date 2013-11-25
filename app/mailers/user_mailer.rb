class UserMailer < ActionMailer::Base
  default from: 'notifications@idlika.com'
 
  def welcome_email(user)
    @user = user
    @url  = 'http://idlika.com/login'
    mail(to: @user.email, subject: 'Welcome to idlika')
  end
end
