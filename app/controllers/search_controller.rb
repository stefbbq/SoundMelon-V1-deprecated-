class SearchController < ApplicationController
  before_filter :require_login, :except => [:check_bandname, :check_bandmentionname]
  
  def index
    
    if params[:a_page].blank? # only fan search      
      @fan_search_results = User.search do
        fulltext params[:q]
        with(:activation_state, 'active')
        paginate :page => params[:f_page], :per_page => SEARCH_FAN_RESULT_PER_PAGE
      end    
    end
    
    if params[:f_page].blank? # only artist search      
      @artist_search_results = Band.search do
        fulltext params[:q]
        paginate :page => params[:a_page], :per_page => SEARCH_ARTIST_RESULT_PER_PAGE
      end
    end
    
    messages_and_posts_count unless request.xhr?
    
    respond_to do |format|
      format.js
      format.html
    end
  end
  
  def autocomplete_suggestions
    @users          = User.where("fname like :search_word or lname like :search_word", :search_word => "#{params[:term]}%").select('Distinct fname, lname').limit(10)
    @band_names     = Band.where("name like :search_word", :search_word => "#{params[:term]}%").select('Distinct name').limit(10).map{|band| band.name}
    @band_genres    = Band.where("genre like :search_word", :search_word => "#{params[:term]}%").select('Distinct genre').limit(10).map{|band| band.genre}
    respond_to do |format|
      format.js
    end
  end
  
  def location_autocomplete_suggestions
    @locations = AdditionalInfo.where("location like :search_word ", :search_word => "#{params[:term]}%").select('Distinct location').limit(10)
    respond_to do |format|
      format.js
    end
  end
  
  def check_bandname
    if Band.where('name = ?', params[:band_name]).count == 0
      render :nothing => true, :status => 200 and return
    else
      render :nothing => true, :status => 409 and return
    end
  end

  def check_bandmentionname
    if Band.where('mention_name = ?', "@#{params[:band_mention_name]}").count == 0
      render :nothing => true, :status => 200 and return
    else
      render :nothing => true, :status => 409 and return
    end
  end
  
end
