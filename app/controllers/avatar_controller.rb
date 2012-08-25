class AvatarController < ApplicationController
  before_filter :require_login, :set_actor_and_entities

  def new
    begin      
      @profile_pic = ProfilePic.new(:user_id =>@user.id)
    rescue =>exp
      logger.error "Error in Avatar::New :=> #{exp.message}"
      render :nothing =>true and return
    end
    respond_to do |format|
      format.js
    end
  end

  def create
    begin      
      @profile_pic  = @user.build_profile_pic(params[:profile_pic])
    rescue =>exp
      logger.error "Error: #{exp.message}"
      @user         = nil
    end
    respond_to do |format|
      if @profile_pic.save
        @original_geometry = @profile_pic.avatar_geometry(:original)
        set_height_and_width @original_geometry
        format.js { render :action => 'crop' and return }
      else
        format.js { render :action => 'new' and return}
      end
    end
  end

  def edit    
  end

  def update    
    if @profile_pic.update_attributes(params[:profile_pic])
      respond_to do |format|
        format.js
      end
    end
  end

  def crop
    @ratio = @profile_pic.avatar_geometry(:original).width / @profile_pic.avatar_geometry(:original).height
    @original_geometry = @profile_pic.avatar_geometry(:original)
    set_height_and_width @original_geometry
  end

  def delete    
    redirect_to fan_home_url and return unless @profile_pic
    if @profile_pic.delete
      respond_to do |format|
        format.js
      end
    end
  end

  def new_logo
    begin
      @item_logo        = @item.is_artist? ? ArtistLogo.new(:artist_id=>@item.id) : VenueLogo.new(:venue_id=>@item.id)
    rescue =>exp
      logger.error "Error in Avatar::NewLogo :=> #{exp.message}"
    end
    respond_to do |format|
      format.js
    end
  end

  def create_logo
    begin      
      @item_logo        = @item.is_artist? ? @item.build_artist_logo(params[:artist_logo]) : @item.build_venue_logo(params[:venue_logo])
    rescue =>exp
      logger.error "Error in AvatarCreateLogo :=> #{exp.message}"
      @item         = nil
    end
    respond_to do |format|
      if @item_logo.save
        @original_geometry = @item_logo.logo_geometry(:original)
        set_height_and_width @original_geometry
        format.js { render :action => 'crop_logo' and return }
      else
        format.js { render :action => 'new_logo' and return}
      end
    end
  end

  def edit_logo    
  end

  def update_logo
    status = @item_logo.respond_to?('artist_id') ? @item_logo.update_attributes(params[:artist_logo]) : @item_logo.update_attributes(params[:venue_logo])
    if status
      respond_to do |format|
        format.js
      end
    end
  end

  def crop_logo
    @original_geometry = @artist_logo.logo_geometry(:original)
    set_height_and_width @original_geometry
  end

  def delete_logo    
    redirect_to fan_home_url and return unless @item_logo
    if @item_logo.delete
      respond_to do |format|
        format.js
      end
    end
  end

  private

  def set_actor_and_entities
    if request.xhr?
      begin
        @actor = current_actor
        if @actor.is_fan?
          @user           = @actor
          @profile_pic    = @actor.profile_pic
        elsif @actor.is_artist?
          @item           = @actor
          @item_logo      = @actor.artist_logo
        elsif @actor.is_venue?
          @item           = @actor
          @item_logo      = @actor.venue_logo
        end
      rescue =>exp
        logger.error "Error in Avatar::SetActorAndEntities :=> #{exp.message}"
      end
    else
      render :template =>'/bricks/page_missing'
    end
  end

  def set_height_and_width geometry    
    img_height      = 400
    img_width       = 400
    height          = geometry.height
    width           = geometry.width
    @show_height    = height > img_height ? img_height : height
    @show_width     = width > img_width ? img_width : width
    @height_change  = (height/img_height)
    @width_change   = (width/img_width)
    @is_cropping    = false
  end

end
