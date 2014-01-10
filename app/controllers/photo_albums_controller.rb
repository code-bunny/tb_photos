class PhotoAlbumsController < ApplicationController

  respond_to :html, :json, :xml
  layout Spud::Photos.base_layout

  if Spud::Photos.galleries_enabled
    before_filter :get_gallery
  end

  def index
    if @photo_gallery
      @photo_albums = @photo_gallery.albums.order('created_at desc')
    else
      @photo_albums = SpudPhotoAlbum.order('created_at desc')
    end
    respond_with @photo_albums
  end

  def show
    @photo_album = SpudPhotoAlbum.where(:url_name => params[:id]).first
    if @photo_album.blank?
      raise Spud::NotFoundError.new(:item => 'photo album')
    else
      respond_with @photo_album
    end
  end

private

  def get_gallery
    @photo_gallery = SpudPhotoGallery.where(:url_name => params[:photo_gallery_id]).first
    if @photo_gallery.blank?
      raise Spud::NotFoundError.new(:item => 'photo gallery')
    end
  end

end
