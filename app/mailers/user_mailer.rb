class UserMailer < ActionMailer::Base
  default from: "merosathilai@gmail.com"

  def activation_needed_email(user)
    @user = user
    @url  = user_activation_url(user.activation_token)
    mail(
      :to => user.email,
      :subject => "Thanks for signing up"
    )
  end
  
  def reset_password_email(user)
    @user = user
    @url  = "#{root_url}/password_resets/#{user.reset_password_token}/edit"
    mail(:to => user.email,
      :subject => "Your password reset request")
  end


  def activation_success_email(user)
    @user = user
    @url  = root_url
    mail(
      :to => user.email,
      :subject => "Your account is now activated"
    )
  end
  
  def mate_invitation_email(band_invitation)
    @band_invitation = band_invitation
    @user = User.find(band_invitation.user_id)
    @band = Band.find(@band_invitation.band_id)
    @new_user_url = join_band_invitation_url(band_invitation.token, :old_user => 0 )
    @old_user_url = join_band_invitation_url(band_invitation.token, :old_user => 1 )
      
    mail(
      :to => band_invitation.email,
      :subject => "#{@user.fname} #{@user.lname}  has invited you to join his/her band at soundmelon  "
    )
  end
  
  def friend_invitation_email(toemail, invitee_full_name=' ', user)
    @user = user
    invitee_full_name_arr = invitee_full_name.split(' ')
    if(invitee_full_name_arr.size >1)
      fname = invitee_full_name_arr.first.to_s
      lname = invitee_full_name_arr.last.to_s
    else
      fname = invitee_full_name_arr.first.to_s
      lname = ''
    end
    @url  = fan_registration_url + "?email=#{toemail}&fname=#{fname}&lname=#{lname}"
    @toemail = toemail
    mail(
      :to => toemail,
      :subject => "#{@user.fname} #{@user.lname}  has invited you to join soundmelon  "
    )
  end

  def app_invitation_email(invitation, signup_url)
    @signup_url = signup_url
    @toemail    = invitation.recipient_email
    mail(
      :to => @toemail,
      :subject => "Signup Invitation"
    )
  end

  def feedback_notification_email feedback, feedback_topic, user
    @user             = user
    @feedback_subject = feedback.subject
    @content          = feedback.content
    @toemail          = feedback_topic.emails.split(';')
    mail(
      :to => @toemail,
      :subject => "New Feedback Notification"
    )
  end
  
end
