require 'tb_core'
require 'paperclip'

module Spud
  module Photos
    class Engine < Rails::Engine
      engine_name :tb_photos
      initializer :assets_photos do |config| 
        Spud::Core.append_admin_javascripts("admin/photos/application")
        Spud::Core.append_admin_stylesheets("admin/photos/application")
      end
      initializer :admin do
        Spud::Core.config.admin_applications += [{
          :name => 'Photo Albums',
          :thumbnail => 'admin/photos/photo_albums_thumb.png',
          :url => '/admin/photo_albums',
          :retina => true,
          :order => 82
        # },{
        #   :name => 'Photos',
        #   :thumbnail => 'spud/photos/photo_albums_thumb.png',
        #   :url => '/spud/admin/photos',
        #   :retina => true,
        #   :order => 83
        }]
        if Spud::Photos.config.galleries_enabled
          Spud::Core.config.admin_applications += [{
            :name => 'Photo Galleries',
            :thumbnail => 'admin/photos/photo_albums_thumb.png',
            :url => '/admin/photo_galleries',
            :retina => true,
            :order => 81
          }]
        end
      end
    end
  end
end
