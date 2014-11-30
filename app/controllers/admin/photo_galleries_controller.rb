class Admin::PhotoGalleriesController < Admin::ApplicationController

  before_filter :get_gallery, :only => [:show, :edit, :update, :destroy]
  before_filter :get_albums, :only => [:new, :create, :edit, :update]
  add_breadcrumb 'Photo Galleries', :admin_photo_galleries_path
  layout 'admin/spud_photos'
  belongs_to_spud_app :photo_galleries

  def index
    @photo_galleries = SpudPhotoGallery.all
    respond_with @photo_galleries
  end
  
  def show
    respond_with @photo_gallery
  end
  
  def new
    @photo_gallery = SpudPhotoGallery.new
    respond_with @photo_gallery
  end
  
  def create
    @photo_gallery = SpudPhotoGallery.new(photo_gallery_params)
    flash[:notice] = 'SpudPhotoGallery created successfully' if @photo_gallery.save
    respond_with @photo_gallery, :location => admin_photo_galleries_path
  end
  
  def edit
    respond_with @photo_gallery
  end
  
  def update
    @photo_gallery.update_attributes(photo_gallery_params)
    flash[:notice] = 'SpudPhotoGallery updated successfully' if @photo_gallery.save
    respond_with @photo_gallery, :location => admin_photo_galleries_path
  end
  
  def destroy
    flash[:notice] = 'SpudPhotoGallery deleted successfully' if @photo_gallery.destroy
    respond_with @photo_gallery, :location => admin_photo_galleries_path
  end

private

  def get_gallery
    @photo_gallery = SpudPhotoGallery.find(params[:id])
  end

  def get_albums
    @photo_albums = SpudPhotoAlbum.all
  end

  def photo_gallery_params
    params.require(:spud_photo_gallery).permit(:title, :url_name, :album_ids => [])
  end

end
