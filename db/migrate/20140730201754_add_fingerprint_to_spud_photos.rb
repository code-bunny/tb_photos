class AddFingerprintToSpudPhotos < ActiveRecord::Migration
  def change
    add_column :spud_photos, :photo_fingerprint, :string
    add_index :spud_photos, :photo_fingerprint
  end
end
