class Admin::PhotoAlbumsController < Admin::ApplicationController

  before_filter :get_album, :only => [:show, :edit, :update, :destroy, :library]
  add_breadcrumb 'Photo Albums', :admin_photo_albums_path
  layout 'admin/spud_photos'

  def index
    @photo_albums = SpudPhotoAlbum.all
    respond_with @photo_albums
  end

  def show
    respond_with @photo_album
  end

  def new
    @photo_album = SpudPhotoAlbum.new
    respond_with @photo_album
  end

  def create
    @photo_album = SpudPhotoAlbum.new(photo_album_params)
    if @photo_album.save
      set_photo_order
    end
    respond_with @photo_album, :location => admin_photo_albums_path
  end

  def edit
    respond_with @photo_album
  end

  def update
    @photo_album.update_attributes(photo_album_params)
    if @photo_album.save
      set_photo_order
      flash[:notice] = 'SpudPhotoAlbum updated successfully' 
    end
    respond_with @photo_album, :location => admin_photo_albums_path
  end

  def destroy
    flash[:notice] = 'SpudPhotoAlbum deleted successfully' if @photo_album.destroy
    respond_with @photo_album, :location => admin_photo_albums_path
  end

  def get_album
    @photo_album = SpudPhotoAlbum.find(params[:id])
  end

private

  def set_photo_order
    order_ids = params[:spud_photo_album][:photo_ids] || []
    @photo_album.spud_photo_albums_photos.each do |obj|
      #logger.debug "##### ID: #{obj.spud_photo_id.to_s}"
      index = order_ids.index(obj.spud_photo_id.to_s)
      obj.update_attribute(:sort_order, index)
    end
  end

  def photo_album_params
    params.require(:spud_photo_album).permit(:title, :url_name, :photo_ids => [])
  end

end
