class PhotoAlbumsController < ApplicationController

  respond_to :html, :json, :xml
  layout Spud::Photos.base_layout

  if Spud::Photos.galleries_enabled
    before_filter :get_gallery
  end

  def index
    if @photo_gallery
      @photo_albums = @photo_gallery.albums.ordered
    else
      @photo_albums = SpudPhotoAlbum.ordered
    end
    respond_with @photo_albums
  end

  def show
    @photo_album = SpudPhotoAlbum.find_by(:url_name => params[:id])
    if @photo_album.blank?
      raise Spud::NotFoundError.new(:item => 'photo album')
    else
      respond_with @photo_album
    end
  end

private

  def get_gallery
    @photo_gallery = SpudPhotoGallery.find_by(:url_name => params[:photo_gallery_id])
    if @photo_gallery.blank?
      raise Spud::NotFoundError.new(:item => 'photo gallery')
    end
  end

end
