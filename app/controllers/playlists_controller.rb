class PlaylistsController < ApplicationController
  before_filter :require_login
  before_filter :check_xhr_request
  
  def add
    begin
      song = Song.find(params[:id])
      Playlist.add_song_for(current_user.id, song.id)
    rescue
      render :nothing => 'true' and return
    end
  end
  
  def remove
    begin
      song = Song.find(params[:id])
      Playlist.remove_song_for(current_user.id, song.id)
    rescue
      render :nothing => 'true' and return
    end
  end
  
  def add_all_songs_of_album
    begin
      song_album = SongAlbum.find(params[:id])
      Playlist.add_whole_album_songs_for(current_user.id, song_album)
    rescue
      render :nothing => 'true' and return
    end
  end

  def add_to_player_queue
    @song_album = SongAlbum.where("id=?", params[:id]).includes(:songs).first
  end
  
  private
  
  def check_xhr_request
    redirect_to root_url and return unless request.xhr?
  end
  
end
