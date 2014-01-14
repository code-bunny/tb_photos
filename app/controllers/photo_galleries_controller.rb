class PhotoGalleriesController < ApplicationController

  respond_to :html, :json, :xml
  layout Spud::Photos.base_layout

  def index
    @photo_galleries = SpudPhotoGallery.order('created_at desc')
    respond_with @photo_galleries
  end

end
