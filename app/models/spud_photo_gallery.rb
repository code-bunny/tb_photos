class SpudPhotoGallery < ActiveRecord::Base

  has_many :spud_photo_galleries_albums, :dependent => :destroy
  has_many :albums,
    :through => :spud_photo_galleries_albums,
    :source => :spud_photo_album

  validates_presence_of :title, :url_name
  validates_uniqueness_of :title, :url_name
  before_validation :set_url_name

  scope :ordered, ->{ order('created_at desc') }

  def top_photo_url(style)
    unless albums.empty?
      return albums.first.top_photo_url(style)
    end
  end

  def albums_available
    if album_ids.any?
      return SpudPhotoAlbum.where('id not in (?)', album_ids)
    else
      return SpudPhotoAlbum.all
    end
  end

  private

  def set_url_name
    if self.title
      self.url_name = self.title.parameterize
    end
  end

end
