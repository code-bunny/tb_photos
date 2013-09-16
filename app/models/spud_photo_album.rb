class SpudPhotoAlbum < ActiveRecord::Base

  attr_accessible :title, :url_name, :photos, :photo_ids

  has_many :spud_photo_albums_photos, :dependent => :destroy
  has_many :photos,
    :through => :spud_photo_albums_photos,
    :source => :spud_photo,
    :order => 'spud_photo_albums_photos.sort_order asc'

  has_many :spud_photo_galleries_albums
  has_many :galleries,
    :through => :spud_photo_galleries_albums,
    :source => :spud_photo_gallery

  validates_presence_of :title, :url_name
  validates_uniqueness_of :title, :url_name
  before_validation :set_url_name
  after_save :update_photo_order

  def top_photo_url(style)
    if photos.length > 0
      return photos.first.photo.url(style)
    end
  end

  def photos_available
    if photo_ids.any?
      return SpudPhoto.where('id not in (?)', photo_ids)
    else
      return SpudPhoto.all
    end
  end

  private

  def set_url_name
    self.url_name = self.title.parameterize
  end

  def update_photo_order
    # order = 0
    # self.photos.each do |p|
    #   p.update_attribute(:order, order)
    #   order += 1
    # end
  end

end
