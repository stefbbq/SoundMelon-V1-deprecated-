class UserMailer < ActionMailer::Base
  default from: "SoundMelon<admin@soundmelon.com>"

  # fix for SystemStackError problem
  # message sending with delay produces such error
  def encode_with coder
  end

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

  def app_invitation_email(invitation)
    @invitation_token   = invitation.token
    @toemail            = invitation.recipient_email
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

  def general_notification_email notification_type, subject, recipient_object, actor_object, action_item=nil, content_item = nil, artist=nil
    @action_item      = action_item
    @content_item     = content_item
    @actor            = actor_object
    @recipeint        = recipient_object
    @artist           = artist
    @toemail          = recipient_object.email    
    notification_for  = notification_type.blank? ? nil : NotificationMail::NOTIFICATION_TYPES.index(notification_type)
    if notification_for
      template_sets   = [
                        'follow_notification_email',
                        'connect_notification_email', 'connect_request_notification_email',
                        'message_notification_email', 'reply_notification_email',                        
                        'mention_notification_email', 'buzz_notification_email'
                        ]
      template_name   = template_sets[notification_for]
      mail(
        :from           => "SoundMelon<notifications@soundmelon.com>",
        :to             => @toemail,
        :subject        => subject,
        :template_path  => 'notifications',
        :template_name  => template_name
      )
    end
  end
  
end
