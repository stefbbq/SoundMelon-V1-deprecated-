Soundmelon::Application.routes.draw do

  resources :invitations  

  get "artist/index"

  # pages and feedback
  get "feedbacks"                             => "user#feedback_page",              :as => :feedback_start
  match "/feedback/send"                      => "user#give_feedback",              :as => :send_feedback
  get 'page/:page_name'                       => 'page#show',                       :as => :page
  #global
  get "search/index"
  get 'logout'                                => 'sessions#destroy',                :as => :logout
  post 'login'                                => 'sessions#create',                 :as => :login

  get 'ChangeLogin(/:artist_name)'            => 'user#change_login',               :as => :change_login

  # administrator section
  get '/home/admin/feedbacks'                 => 'admin#feedbacks',                 :as => :admin_feedbacks_list
  get '/home/admin/feedback/:id/:opcode'      => 'admin#feedback_handler',          :as => :admin_feedback_handler
  get '/home/admin(/:sent)'                   => 'admin#index',                     :as => :admin_home #home  
  get '/home/admin/:id/:opcode'               => 'admin#invitation_request_handler',:as => :request_handler
  #fan
  get '/home'                                 => 'user#index',                      :as => :user_home #home
  #fan
  get '/home'                                 => 'user#index',                      :as => :fan_home #home
  get 'home/post/:id/threads'                 => 'user_posts#post_threads',         :as => :get_post_threads #posts
  get 'home/mentions'                         => 'user_posts#mentioned',            :as => :mentioned #mentions
  get 'home/replies'                          => 'user_posts#replies',              :as => :replies #replies
  match 'home/messages'                       => 'messages#inbox',                  :as => :user_inbox #messages

  #-------------------------------------------- followings, followers, follower bands, follower fans ---------------
  get 'fan/:id/followers(/:page)'             => 'user_connections#fan_followers',          :as => :fan_followers
  get 'artist/followers/:band_name(/:page)'   => 'user_connections#band_followers',         :as => :band_followers
  get 'artist/connections/:band_name(/:page)' => 'user_connections#artist_connections',     :as => :artist_connections
  get 'fan/following/fans/:id(/:page)'        => 'user_connections#fan_following_fans',     :as => :fan_following_fans # id: following items
  get 'fan/following/artists/:id(/:page)'     => 'user_connections#fan_following_artists',  :as => :fan_following_artists # id: following items
  
  #fan functions
  get 'home/artists'                          => 'user#pull_artist_profiles',       :as => :associated_band
  get 'artist/new/band'                       => 'artist#new',                      :as => :new_band
  post 'artist/create/band'                   => 'artist#create',                   :as => :create_band
  match 'home/manage/profile'                 => 'user#manage_profile',             :as => :manage_profile #manage session profile
#  match 'home/manage'                         => 'fan#manage_profile',             :as => :manage_profile #manage session profile
    
  #fan public
  match 'fan/(:id)'                           => 'fan_public#index',                :as => :fan_profile
  match 'fan/posts/:id'                       => 'fan_public#latest_posts',         :as => :fan_latest_post

  match 'fan/home/check_password'             => 'user#check_user_validity',        :as => :ask_and_check_user_password
  
  #artist
  get 'home/artist/:band_name'                => 'artist#index',                    :as => :manage_band
#  get 'edit/artist/:band_name/:id'            => 'artist#edit',                    :as => :edit_band
  match 'update/band/:id'                     => 'artist#update',                   :as => :update_band
  get ':band_name/bandmates/invitation'       => 'artist#invite_bandmates',         :as => :bandmates_invitation
  get ':band_name/social'                     => 'artist#social',                   :as => :band_social
  get ':band_name/store'                      => 'artist#store',                    :as => :band_store
  match ':band_name/bandmates/send/inviation' => 'artist#send_bandmates_invitation',:as => :send_bandmates_invitation

  get "profile/additional_info"
  
  match 'registration(/:invitation_token)'    => 'fan#signup',                            :as => :fan_registration
  get 'users/:id/activate'                    => 'fan#activate',                          :as => :user_activation
  get 'user/reset/password'                   => 'password_resets#index',                 :as => :password_reset
  post 'add/additional_info'                  => 'fan#add_additional_info',               :as => :create_additional_info
  post 'add/payment_info'                     => 'fan#add_payment_info',                  :as => :create_payment_info
  match "invite/bandmates"                    => "fan#invite_bandmates" ,                 :as => :invite_band_member
  #get "invite/accept/:id/join" => "profile#activate_invitation" ,:as => "join_band_invitation"
  match 'invitation/accept/:old_user/:id/join'=> 'fan#activate_invitation' ,              :as => :join_band_invitation
  match "messages/sendmessage"                => 'messages#send_message',                 :as => :send_message

  resources :user_posts
  match 'post/:id/reply/(:band_id)'           => 'user_posts#new_reply',                  :as => :new_post_reply
  match 'post/reply'                          => 'user_posts#reply',                      :as => :post_reply
  
  get ':band_name/mentioned/posts'            => 'user_posts#mentions_post',              :as => :band_mentions_post
  get ':band_name/replies/posts'              => 'user_posts#replies_post',               :as => :band_replies_post
  
  resources :messages
 
  match 'message/reply'                       =>'messages#reply' ,                        :as => :reply_to_message
  match '(:band_name)/inbox/messages/:page'   =>'messages#index',                         :as => :more_inbox_messages
  match '(:type)/posts/more/:page'            =>'user_posts#index',                       :as => :more_post
  match 'user/:id/posts/more/:page'           =>'user_posts#index',                       :as => :user_more_post
  match ':band_name/bulletins/more/:page'     =>'user_posts#more_bulletins',              :as => :band_more_bulletins
  match ':band_name/(:type)/posts/more/:page' =>'user_posts#more_posts',                  :as => :band_more_posts

  match 'update/basic/profile'                => 'fan#update_basic_info',                 :as => :update_basic_info
  match 'update/additional/info'              => 'fan#update_additional_info',            :as => :update_additional_info
  match 'update/password'                     => 'fan#update_password',                   :as => :update_password  
  match 'edit/payment/info'                   => 'fan#update_payment_info',               :as => :edit_payment_info
  match 'update/notification/setting'         => 'fan#update_notification_setting',       :as => :update_notification_setting
  match 'update/artist/notification/:id'      => 'artist#update_notification_setting',    :as => :update_artist_notification_setting
  
  #--------------------------------------------------AvatarController[Fan Profile Pic/Artist Logo]----------------------
  post 'profile/pic/add'                      => 'avatar#create',                         :as => :add_avatar
  get 'profile/pic/new'                       => 'avatar#new',                            :as => :new_avatar
  match 'profile/pic/crop'                    => 'avatar#crop',                           :as => :crop_avatar
  match 'profile/pic/update'                  => 'avatar#update',                         :as => :update_avatar
  get 'profile/pic/delete'                    => 'avatar#delete',                         :as => :delete_avatar

  post 'artist/logo/add'                      => 'avatar#create_logo',                    :as => :add_logo
  get 'artist/logo/new'                       => 'avatar#new_logo',                       :as => :new_logo
  match 'artist/logo/crop'                    => 'avatar#crop_logo',                      :as => :crop_logo
  match 'artist/logo/update'                  => 'avatar#update_logo',                    :as => :update_logo
  get 'artist/logo/delete'                    => 'avatar#delete_logo',                    :as => :delete_logo


  # match 'profile/pic/delete' => 'avatar#delete', :as => 'delete_avatar'
  resources :password_resets
  match '/user/resest/password/:id'           => 'password_resets#update',                :as => :reset_password
  resources :photos
  get 'albums'                                => 'photos#albums',                         :as => :albums
  get 'album/photos/:album_name'              => 'photos#album_photos',                   :as => :album_photos
  get ':album_name/photo/:id'                 => 'photos#show',                           :as => :album_photo
  
  #invitation
  match 'contacs/fetch'                       => "invite#fetch_contacts",                 :as => :fetch_contacts
  post 'send/invitation'                      => "invite#send_invitation",                :as => :send_invitation
 
  #autocomplete
  match 'autocomplete/suggestions'            => 'search#autocomplete_suggestions',       :as => :autocomplete_suggestions
  match 'autocomplete/location/suggestions'   => 'search#location_autocomplete_suggestions',      :as => :location_autocomplete_suggestions
  get 'check/bandname'                        => 'search#check_bandname',                 :as => :check_bandname
  get 'check/bandmentionname'                 => 'search#check_bandmentionname',          :as => :check_bandmentionname
  #get 'fan/sign_up/message' => 'users#fan_signup_sucessful_info', :as => successful_fan_signup
  #get 'musician/sign_up/message' => 'users#musician_signup_sucessful_info', :as => successful_musician_signup

  # Band Shows
  get ':band_name/show/new'                       => 'band_tour#new',                     :as => :new_band_tour
  get ':band_name/shows'                          => 'band_tour#band_tours',              :as => :band_tours
  get ':band_name/:band_tour_id/show'             => 'band_tour#band_tour',               :as => :band_tour
  get ':band_name/:band_tour_id/showdetail'       => 'band_tour#band_tour_detail',        :as => :band_tour_detail
  get ':band_name/showchange/:band_tour_id'       => 'band_tour#edit',                    :as => :edit_band_tour
  get ':band_name/showlike/:band_tour_id'         => 'band_tour#like_dislike_band_tour',  :as => :like_dislike_band_tour
  match ':band_name/showremove/:band_tour_id'     => 'band_tour#destroy_tour',            :as => :delete_band_tour

  resources :album_photos
  get ':band_name/album/new'                      => 'band_photos#new',                   :as => :new_band_album
  get ':band_name/albums'                         => 'band_photos#band_albums',           :as => :band_albums
  get ':band_name/:band_album_name/palbum'        => 'band_photos#band_album',            :as => :band_album
  get ':band_name/album/photos/:band_album_name'  => 'band_photos#band_album_photos',     :as => :band_album_photos
  get ':band_name/:band_album_name/photo/:id'     => 'band_photos#show',                  :as => :band_album_photo
  get ':band_name/:band_album_name/photos/add'    => 'band_photos#add',                   :as => :add_photos_to_album
  get ':band_name/edit/:band_album_name'          => 'band_photos#edit',                  :as => :edit_album
  match ':band_name/delete/:band_album_name'      => 'band_photos#destroy_album',         :as => :delete_album
  get ':band_name/:album_name/photo/:id/cover'    => 'band_photos#make_cover_image' ,     :as => :make_cover_image
  get ':band_name/:album_name/photo/:id/edit'     => 'band_photos#edit_photo' ,           :as => :edit_photo
  get ':band_name/:album_name/photo/:id/delete'   => 'band_photos#destroy' ,              :as => :delete_photo
  get ':band_name/:album_name/ppublic'            => 'band_photos#disable_enable_band_album', :as => :disable_enable_band_album
  match ':band_name/:album_name/photo/:id/update' => 'band_photos#update_photo',          :as => :update_band_photo
  get ':band_name/:album_name/plike'              => 'band_photos#like_dislike',          :as => :like_band_album
  
  #band song albums and songs
  get ':band_name/song/album/new'                 => 'band_song_album#new',               :as => :new_band_song_album
  get ':band_name/song/albums'                    => 'band_song_album#band_song_albums',  :as => :band_song_albums
  get ':band_name/:song_album_name/album'         => 'band_song_album#band_song_album',   :as => :band_song_album
  get ':band_name/album/songs/:song_album_name'   => 'band_song_album#album_songs',       :as => :band_album_songs
  get ':band_name/song/:id/edit'                  => 'band_song_album#edit_song',         :as => :album_song_edit
  get ':band_name/:song_album_name/songs/add'     => 'band_song_album#add',               :as => :add_songs_to_album
  match ':band_name/song/:id/update' => 'band_song_album#update_song',                    :as => :album_song_update
  get ':band_name/SongAlbum/sadownload/:id'       => 'band_song_album#download_album',    :as => :download_song_album
  match ':band_name/album/delete/:song_album_id'  => 'band_song_album#destroy_album',     :as => :delete_song_album
  match ':band_name/song/delete/:song_id'         => 'band_song_album#destroy_song',      :as => :delete_song
  get ':band_name/:song_album_name/public'        => 'band_song_album#disable_enable_song_album', :as => :disable_enable_band_song_albums  
  get ':band_name/set_featured_songs'             => 'band_song_album#songs_for_featured_list',   :as => :popup_for_feature_songs
  get ':band_name/:song_album_name/featured'      => 'band_song_album#make_song_album_featured',  :as => :make_song_album_featured
  get ':band_name/:song_album_name/featured/:id'  => 'band_song_album#make_song_featured',:as => :make_song_featured
  get ':band_name/:song_album_name/edit'          => 'band_song_album#edit_song_album',   :as => :edit_band_song_album  
  get ':song_name/:id/like(/:do_like)'            => 'band_song_album#do_like_dislike_song',      :as => :like_song
  
  root :to => 'home#index'

  
  #--------------------------------------------UserConnections----------------------------------------------------
  # follow/un-follow band
  get 'follow/artist/:band_name(/:self)'          => 'user_connections#follow_band',       :as => :follow_band
  get 'unfollow/artist/:band_name(/:self)'        => 'user_connections#unfollow_band',     :as => :unfollow_band
  get 'connection/request/artist/:band_name'      => 'user_connections#connect_artist',    :as => :connect_artist
  get 'connection/accept/artist/:band_name'       => 'user_connections#connect_artist',    :as => :accept_artist_connection
  get 'connection/reject/artist/:band_name'       => 'user_connections#disconnect_artist', :as => :reject_artist_connection
  get 'connection/remove/artist/:band_name'       => 'user_connections#disconnect_artist', :as => :remove_artist_connection
  
  # follow/un-follow fan
  get 'follow/fan/:id(/:self)'            => 'user_connections#follow',                   :as => :follow_user
  get 'unfollow/fan/:id(/:self)'          => 'user_connections#unfollow',                 :as => :unfollow_user
  #---------------------------------------------------------------------------------------------------------------
  #message band
  get ':band_name/message/new'            => 'artist_public#new_message',                 :as => :band_new_message
  match ':band_name/message/create'       => 'artist_public#send_message',                :as => :band_send_message
  get ':band_name/members'                => 'artist_public#members',                     :as => :band_members
  get ':band_name'                        => 'artist_public#index',                       :as => :show_band
  
  #album and song buzz
  get ':band_name/:id/tbuzz'              => 'buzz#band_tour_buzz',                       :as => :band_tour_buzz
  get ':album_name/:id/photo_album_buzz'  => 'buzz#band_photo_album_buzz',                :as => :band_album_buzz
  get ':album_name/:id/buzz'              => 'buzz#album_buzz',                           :as => :album_buzz
  get 'buzz/:id'                          => 'buzz#song_buzz',                            :as => :song_buzz
  #get ':song_name/:id/buzz' => 'buzz#song_buzz', :as => 'song_buzz'
  match ':album_name/:id/buzz/create'     => 'buzz#album_buzz_post',                      :as => :album_buzz_post
  match 'buzz/:id/create'                 => 'buzz#song_buzz_post',                       :as => :song_buzz_post
  match ':album_name/:id/photobuzz/create'=> 'buzz#band_album_buzz_post',                 :as => :band_album_buzz_post
  match 'photobuzz/:id/create'            => 'buzz#band_photo_buzz_post',                 :as => :band_photo_buzz_post
  match 'tbuzz/:id/create'                => 'buzz#band_tour_buzz_post',                  :as => :band_tour_buzz_post

  #match ':song_name/:id/buzz/create' => 'buzz#song_buzz_post', :as => 'song_buzz_post' 
  
  #song download
  get ':artist_name/:id/download'         => 'band_song_album#download',                  :as => :download_song
  
  #playlist  
  get 'playlist/:song_name/:id/add'       => 'playlists#add',                             :as => :add_to_playlist
  get 'playlist/:song_name/:id/remove'    => 'playlists#remove',                          :as => :remove_from_playlist
  get 'playlistPlayer/:id/add'            => 'playlists#add_to_player_queue',             :as => :add_album_to_player_playlist
  get 'playlist/:id/add'                  => 'playlists#add_all_songs_of_album',          :as => :add_album_to_playlist

  get '/home/remove/profile'              => 'user#remove_user_profile',                  :as => :remove_my_profile

  match ':controller(/:action(/:id(.:format)))'
end
