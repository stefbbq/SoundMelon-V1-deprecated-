class ArtistController < ApplicationController
  before_filter :require_login
  
  def index
    begin
      @artist = Artist.where(:mention_name => params[:artist_name]).includes(:artist_members).first
      if @is_admin_of_artist         = current_user.is_admin_of_artist?(@artist)
        get_artist_associated_objects(@artist)        
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to adminster artist with artist id: #{@artist.id} which he is not a admin" 
        redirect_to fan_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  def new
    @user   = current_user
    get_user_associated_objects
    @artist = Artist.new
  end  
  
  def create
    @artist     = current_user.artists.build(params[:artist])
    artist_user = current_user.artist_users.new
    if @artist.save
      artist_user.artist_id       = @artist.id
      artist_user.access_level  = 1
      artist_user.save
      @artists  = current_user.artists.includes(:artist_musics, :songs)
    else
      render :action => 'new' and return
    end
  end
  
  def edit    
    begin      
      @artist       = Artist.find(params[:id])
      @artist_user  = ArtistUser.for_user_and_artist(current_user, @artist).first || ArtistUser.new
      get_artist_objects_for_right_column(@artist)
      if current_user.is_admin_of_artist?(@artist)
        respond_to do |format|
          format.js
          format.html
        end
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to edit artist with artist id: #{@artist.id} which he is not a admin"
        render :nothing => true and return
      end
    rescue =>exp
      logger.error "Error in Artist#Edit :=> #{exp.message}"
      render :template   => "/bricks/page_missing" and return
    end
  end
  
  def update
    @artist     = Artist.find(params[:id])
    get_artist_objects_for_right_column(@artist)
    if current_user.is_admin_of_artist?(@artist)
      if @artist.update_attributes(params[:artist])
        respond_to do |format|
          format.js
        end
      else
        respond_to do |format|
          format.js {render :action => 'edit' and return}
        end
      end
    else
      logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to update artist with artist id: #{@artist.id} which he is not a admin" 
      render :nothing => true and return
    end    
  end

  def update_notification_setting
    if request.xhr?
      @updated           = false
      artist               = Artist.find(params[:id])
      if artist
        artist_user        = ArtistUser.for_user_and_artist(current_user, artist).first
        artist_user.toggle! :notification_on if artist_user
        @status          = artist_user.notification_on ? 'on' : 'off'
        @updated         = true
      end      
    else
      redirect_to fan_home_url and return
    end
  end
  
  def show
    @artist               = Artist.where(:mention_name => params[:artist_name]).includes(:artist_members).first
    @artist_members_count = @artist.artist_members.count
    @is_admin_of_artist   = current_user.is_admin_of_artist?(@artist)
    respond_to do |format|
      format.js
      format.html
    end
  end   
  
  def invite_artist_members
    begin
      @artist      = Artist.where(:mention_name => params[:artist_name]).first
      if current_user.is_admin_of_artist?(@artist)
        1.times { @artist.artist_invitations.new}
        get_artist_objects_for_right_column(@artist)
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to invite artistmate for a artist with artist id: #{@artist.id} which he is not a admin" 
        redirect_to fan_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def send_artist_member_invitation
    begin
      @artist = Artist.where(:mention_name => params[:artist_name]).first
      if current_user.is_admin_of_artist?(@artist)
        invitation_email_array = []
        params['artist']['artist_invitations_attributes'].each do |key, value|
          value['user_id'] = current_user.id unless value.has_key?('id')
          invitation_email_array << {:type =>params[:invitation_by_type], :name =>value['email'], :level =>value['access_level']}
        end        
        number_of_invitation = ArtistInvitation.create_invitation_for_artist current_user, @artist, invitation_email_array
        @msg = "#{number_of_invitation} invitations has been sent"
      else
        logger.error "#User with username:{current_user.get_full_name} and user id #{current_user.id} tried to send invitation for bandmates to join a artist with artist id: #{@artist.id} which he is not a admin" 
        redirect_to fan_home_url, :notice => 'Your action has been reported to admin' and return
      end
    rescue =>exp
      logger.error "Error in Artist::SendArtistmatesInvitation :=>#{exp.message}"
      redirect_to fan_home_url, :notice => 'Something went wrong! Try Again' and return
    end      
  end

  def search_fan_popup
    @artist = Artist.where(:mention_name => params[:artist_name]).first
  end

  def search_fan
    @artist_name         = params[:artist_name]
    @artist_id           = params[:artist_id] ? params[:artist_id].to_i : 0
    @user_search_results = Sunspot.search User do |query|
      query.keywords params[:q]
      query.with :activation_state, 'active'
    end
    @user_search_results      = @user_search_results.results
    unless @user_search_results.blank?
      @artist_member_ids      = ArtistUser.for_artist_id(@artist_id).map{|user| user.user_id}
      @user_search_results.delete_if{|u| @artist_member_ids.include?(u.id)}
      @artist_invitee_emails  = ArtistInvitation.for_artist_id(@artist_id).map{|bi| bi.email}
    end
  end

  def search_fan_invitation
    @artist = Artist.where(:mention_name => params[:artist_name]).first
    @fan    = User.find(params[:id])
    ArtistInvitation.create_invitation_for_artist_and_fan(current_user, @artist, @fan)
  end

end
