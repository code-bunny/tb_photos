class SpudPhotoGalleriesAlbum < ActiveRecord::Base
  belongs_to :spud_photo_album
  belongs_to :spud_photo_gallery, :touch => true
end
