module Spud
  module Photos
    include ActiveSupport::Configurable
    config_accessor :photo_styles, :convert_options, :source_file_options, :galleries_enabled, :base_layout, :base_path,:s3_credentials,:storage_path,:storage_url,:paperclip_storage, :enable_full_page_caching, :page_caches_to_sweep
    self.photo_styles = {
      :small => '50x50#',
      :medium => '200x200#',
      :large => '400x400#'
    }
    self.convert_options = {
      :all => '-strip'
    }
    self.source_file_options = {
      :all => '-density 72'
    }
    self.galleries_enabled = false
    self.base_layout = 'application'
    self.base_path = 'photos'
    self.paperclip_storage = :filesystem
    self.s3_credentials = "#{Rails.root}/config/s3.yml"
    self.storage_path = ":rails_root/public/system/spud_photos/:id/:style/:basename.:extension"
    self.storage_url = "/system/spud_photos/:id/:style/:basename.:extension"
    self.enable_full_page_caching = false
    self.page_caches_to_sweep = []
  end
end
