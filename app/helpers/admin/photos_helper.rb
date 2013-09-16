module Admin::PhotosHelper

  def photo_is_selected
    return (@photo_album && @photo_album.photo_ids.include?(photo.id))
  end

end