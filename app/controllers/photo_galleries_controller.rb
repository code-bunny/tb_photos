class PhotoGalleriesController < ApplicationController

  respond_to :html, :json, :xml
  layout Spud::Photos.base_layout

  after_filter :only => [:index] do |c|
    if Spud::Photos.enable_full_page_caching
      c.cache_page(nil, nil, false)
    end
  end

  def index
    @photo_galleries = SpudPhotoGallery.order('created_at desc').includes(:albums)
    respond_with @photo_galleries
  end

end
