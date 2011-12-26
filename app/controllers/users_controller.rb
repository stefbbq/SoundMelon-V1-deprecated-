class UsersController < ApplicationController
  before_filter :require_login, :except => [:fan_new, :musician_new, :activate]
  before_filter :logged_in_user, :only => ['fan_new', 'musician_new', :activate]  
  def index
    @user = current_user
    #@user_posts = UserPost
    #@user_post_dates = UserPost.where("user_id = (?) or  post like (?)",current_user.id,"%@"+current_user.fname+" %").order("created_at desc").group("date(created_at)")
    @user_posts    = UserPost.listing current_user, params[:page]
    @user_post_dates = @user_posts.group_by{|t| t.created_at.strftime("%Y-%m-%d")}
    
     
      next_page           = @user_posts.next_page
      @load_more_path =  next_page ?  more_post_path(next_page) : nil
      #render @next_user_posts
    #raise @user_post_dates.inspect
    
    @messages = current_user.received_messages.limit(DEFAULT_NO_OF_MESSAGE_DISPLAY)
    @following_count = current_user.following_user.count
    @follower_count = current_user.user_followers.count
    @following_users = current_user.following_user.order('RAND()').limit(NO_OF_FOLLOWING_TO_DISPLAY)
    @follower_users = current_user.user_followers.order('RAND()').limit(NO_OF_FOLLOWER_TO_DISPLAY)
  end
  
  def fan_new
    if request.post?  
        @user = User.new(params[:user])
        @user.account_type = 0
        if verify_recaptcha(:model => @user, :message => "Captha do not match") && @user.save
          @page_type = 'Fan'
          render 'successful_signup_info' and return
        #redirect_to successful_fan_signup_url, :notice => "Signed up successfully! "
	      else
	         render :fan_new
        end    
    else
      @user = User.new
    end
  end

  def musician_new 
    @error_msg = Array.new
    if request.post?
      
      @user = User.new(params[:user])
      @user.account_type = 1
      if !params[:band_name] || !params[:genre]
         redirect_to root_url and return      
      else  
        if params[:band_name].blank? || params[:genre].blank?
          @errors = true
          @error_msg << "Band Name cannot be blank" if params[:band_name].blank?
          @error_msg << "Genre cannot be blank" if params[:genre].blank?
        end
      end
      
      if verify_recaptcha(:model => @user, :message => "Captha do not match") && @user.valid? && !@errors
         begin
          band = Band.new  
          band_user = BandUser.new
          BandUser.transaction do
            @user.save!
            band.name = params[:band_name].strip
            band.genre = params[:genre].strip
            band.save!
          
            band_user.user_id = @user.id
            band_user.band_id = band.id
            band_user.access_level = 1
            band_user.save!
            @page_type = 'Musician'
            render 'successful_signup_info' and return
          end
         rescue
           render :musician_new
         end
          #redirect_to successful_musician_signup_url, :notice => "Signed up successfully!"
	    else
	       render :musician_new
      end    
    else
      @user = User.new
    end
  end
    
  def activate
    if @user = User.load_from_activation_token(params[:id])
      session[:user_id] = @user.id if @user.activate!
      @confirmation_thanks = true
      @additional_info = @user.additional_info
      @payment_info = @user.payment_info
      if @user.account_type
        @page_type = 'Musician'
      else
        @page_type = 'Fan'
      end
      render 'profile/additional_info' and return
      #redirect_to root_url, :notice => 'User was successfully activated.'
    else
      redirect_to root_url, :notice => 'Unable to activate your account. Try Again!'
    end
  end
  
end
