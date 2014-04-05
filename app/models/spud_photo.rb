class SpudPhoto < ActiveRecord::Base

  extend ActionView::Helpers::NumberHelper

  has_many :spud_photo_albums_photos, :dependent => :destroy
  has_many :albums,
    :through => :spud_photo_albums_photos,
    :source => :spud_photo_album

  has_attached_file :photo, 
    :styles => lambda { |attachment| attachment.instance.dynamic_styles },
    :convert_options => Spud::Photos.convert_options,
    :source_file_options => Spud::Photos.source_file_options,
    :storage => Spud::Photos.paperclip_storage,
    :s3_credentials => Spud::Photos.s3_credentials,
    :url => Spud::Photos.storage_url,
    :path => Spud::Photos.storage_path

  validates_attachment :photo,
    :presence => true,
    :content_type => {:content_type => ['image/jpg', 'image/jpeg', 'image/png']},
    :size => {
      :less_than => Spud::Photos.max_image_upload_size,
      :message => "size cannot exceed " + number_to_human_size(Spud::Photos.max_image_upload_size), 
      :if => Proc.new{|p| Spud::Photos.max_image_upload_size > 0}
    }

  def dynamic_styles
    admin_styles = {
      :spud_admin_small => {:geometry => '125x125#', :format => :jpg, :source_file_options => '-density 72', :convert_options => '-strip -quality 85'},
      :spud_admin_medium => {:geometry => '300x200', :format => :jpg, :source_file_options => '-density 72', :convert_options => '-strip -quality 85'}
    }
    return admin_styles.merge(Spud::Photos.config.photo_styles)
  end

end
