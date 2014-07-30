class Admin::PhotosController < Admin::ApplicationController

  include RespondsToParent

  before_filter :get_photo, :only => [:show, :edit, :update, :destroy]
  layout false

  def index
    @photos = SpudPhoto.all
    respond_with @photos
  end

  def show
    respond_with @photo
  end

  def new
    @photo = SpudPhoto.new
    respond_with @photo do |format|
      format.js { render 'new', :layout => false }
    end
  end

  def create
    photo_file = photo_params[:photo]
    if photo_file.present?
      fingerprint = Digest::MD5.hexdigest(photo_file.read)
      photo_file.rewind
      @photo = SpudPhoto.where(:photo_fingerprint => fingerprint).first
    end
    
    if @photo.blank?
      @photo = SpudPhoto.new(photo_params)
    end

    if @photo.save
      success = true
      flash[:notice] = 'SpudPhoto created successfully' 
    end
    if request.xhr?
      render json_for_photo(success)
    else
      respond_to_parent do
        render 'show.js'
      end
    end
  end

  def edit
    respond_with @photo do |format|
      format.js { render 'edit', :layout => false }
    end
  end
  
  def update
    @photo.update_attributes(photo_params)
    if @photo.save
      success = true
      flash[:notice] = 'SpudPhoto updated successfully' 
    end
    if request.xhr?
      render json_for_photo(success)
    else
      respond_to_parent do
        render 'show.js'
      end
    end
  end

  def destroy
    flash[:notice] = 'SpudPhoto deleted successfully' if @photo.destroy
    respond_with @photo, :location => admin_photos_path
  end

  def mass_destroy
    @photos = SpudPhoto.where(:id => params[:spud_photo_ids])
    flash[:notice] = 'Photos deleted successfully' if @photos.destroy_all
    respond_with @photos, :location => admin_photos_path
  end

private

  def get_photo
    @photo = SpudPhoto.find(params[:id])
  end
  
  def json_for_photo(success)
    if success
      return {:status => 200, :json => { 
        :id => @photo.id, 
        :html => render_to_string(:partial => 'photo', :locals => {:photo => @photo}, :layout => nil)
      }}
    else
      return {:status => 422, :json => {
        :id => 0,
        :html => render_to_string(:partial => 'form', :layout => nil)
      }}
    end
  end

  def photo_params
    params.require(:spud_photo).permit(:title, :caption, :photo)
  end

end
