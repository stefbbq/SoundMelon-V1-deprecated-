class BandInvitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :band
  
  
end
