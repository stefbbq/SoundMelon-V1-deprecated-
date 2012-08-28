class FanController < ApplicationController
  before_filter :require_login, :except => [:signup, :musician_new, :activate, :new, :signup_success]
  before_filter :logged_in_user, :only  => [:activate]

  def index    
  end

  def signup
    if current_user
      redirect_to user_home_path
    else
      if request.post?
        session[:user_params]   ||= {:invitation_token =>params[:invitation_token]}
        session[:user_params].deep_merge!(params[:user]) if params[:user]
        @user                     = User.new(session[:user_params])
        @user.current_step        = session[:user_step]
        if @user.valid?
          if params[:back_button]
            @user.previous_step
          elsif @user.last_step?
            @user.save if @user.all_valid?
          else            
            @user.build_location
            @user.next_step
          end
          session[:user_step]     = @user.current_step          
        end
        
        unless @user.new_record?
          session[:user_step]   = nil
          session[:user_params] = nil
          flash[:notice]        = "Account created!"
          render :action        =>'signup_success' and return
        end
      else
        session[:user_params]   = nil
        session[:user_step]     = nil
        session[:user_params]   ||= {:invitation_token =>params[:invitation_token]}
        @user                   = User.new(session[:user_params])
        @user.invitation_token  = params[:invitation_token]
        @user.current_step      = session[:user_step]
        if @user.invitation
          @user.email                 = @user.invitation.recipient_email
          @user.email_confirmation    = @user.invitation.recipient_email
          @is_invited                 = true
        end        
      end
    end    
  end
  
  def activate
    begin      
      if @user = User.load_from_activation_token(params[:id])
        if @user.activate!
          session[:user_id]     = @user.id
          @user.deliver_pending_invitations
        end
        messages_and_posts_count
        @confirmation_thanks  = true
        @additional_info      = @user.additional_info
        @payment_info         = @user.payment_info
        @firstLogin           = true
        #      render 'fan/additional_info' and return
        redirect_to user_home_url, :notice => 'User was successfully activated.' and return
      else        
        redirect_to root_url, :notice => 'Unable to activate your account. Try Again!' and return
      end
    rescue =>exp      
      logger.error "Error in Fan::Activate :=>#{exp.message}"
      redirect_to root_url, :notice => 'Unable to activate your account. Try Again!' and return
    end       
  end

  def additional_info
    @user             = current_user
    @additional_info  = @user.additional_info
    @payment_info     = @user.payment_info
    #redirect_to fan_home_url and return if !@additional_info.nil? || !@payment_info.nil?
  end

  def add_additional_info
    if request.xhr?
      #redirect_to root_url and return unless current_user.additional_info.nil?
      if current_user.additional_info.nil?
        @additional_info = current_user.build_additional_info(params[:additional_info])
        @additional_info.save
      else
        @additional_info_update = true
        @additional_info = current_user.additional_info
        @additional_info.update_attributes(params[:additional_info])
      end
      respond_to do |format|
        format.js
      end
    else
      redirect_to root_url and return
    end
  end

  def add_payment_info
    if request.xhr?
      if current_user.payment_info.nil?
        @payment_info = current_user.build_payment_info(params[:payment_info])
        @payment_info.save
      else
        @payment_info = current_user.payment_info
        @payment_info.update_attributes(params[:payment_info])
        @payment_info_update = true
      end
      respond_to do |format|
        format.js
      end
    else
      redirect_to root_url and return
    end
  end

  def invite_bandmates
    redirect_to root_url and return unless current_user.account_type
    if request.post?
      @artist             = current_user.artists.first
      @artist.update_attributes(params[:artist])
      redirect_to fan_home_url and return
    else
      @artist             = Artist.new
      @artist_invitations = @artist.artist_invitations.build
    end
  end

  def activate_invitation
    unless params[:id].blank?
      artist_invitation = ArtistInvitation.find_by_token(params[:id])
      if artist_invitation
        artist_user = ArtistUser.find_or_create_by_artist_id_and_user_id(artist_invitation.artist_id, current_user.id)
        artist_user.update_attribute(:access_level, artist_invitation.access_level)
        artist_invitation.update_attribute(:token, nil)
        redirect_to show_artist_url(artist_user.artist.name), :notice => "You have successfully joined the artist." and return
      else
        redirect_to fan_home_url ,:error => "Invitation token has been already used or token missmatch" and return
      end
    else
      redirect_to fan_home_url ,:error => "Undefined invitation token" and return
    end
  end

  def update_basic_info
    if request.xhr?
      begin
        if params[:user][:fname].blank? || params[:user][:fname].blank?
          @msg = 'first and last names cannot be blank'
        else
          current_user.fname = params[:user][:fname]
          current_user.lname = params[:user][:lname]
          if current_user.save
            @msg = 'info updated successfully'
          else
            @msg = 'something went wrong, try again'
          end
        end
        respond_to do |format|
          format.js and return
        end
      rescue
        render :nothing => true and return
      end
    else
      redirect_to fan_home_url and return
    end
  end

  def update_password
    if request.xhr?
      begin
        if params[:user][:password_confirmation].blank?
          @msg = 'new password can\'t be blank'
        elsif params[:user][:password] != params[:user][:password_confirmation]
          @msg = 'new password doesn\'t match'
        else
          if current_user.change_password!(params[:user][:password])
            @msg = 'password updated'
          else
            @msg = 'something went wrong, try again'
          end
        end
        respond_to do |format|
          format.js and return
        end
      rescue
        render :nothing => true and return
      end
    else
      redirect_to fan_home_url and return
    end
  end

  def update_payment_info
    if request.xhr?
      @payment_info = current_user.payment_info
    else
      redirect_to fan_home_url and return
    end
  end

  def update_notification_setting
    if request.xhr?
      current_user.toggle! :notification_on
      @status   = current_user.notification_on ? 'on' : 'off'
    else
      redirect_to fan_home_url and return
    end
  end

  def signup_success
  end
  
end