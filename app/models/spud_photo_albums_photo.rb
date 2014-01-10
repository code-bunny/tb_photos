class SpudPhotoAlbumsPhoto < ActiveRecord::Base
  belongs_to :spud_photo
  belongs_to :spud_photo_album
end