# database flag that signals if an image is generating or not.
class AddTileImageGeneratingFlag < ActiveRecord::Migration
  def up
    add_column :tiles, :picture_generating, :boolean
  end
  def down
    remove_column :tiles, :picture_generating
  end
end
