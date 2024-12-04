class AddColumnsToTiles < ActiveRecord::Migration
  def up
    add_column :tiles, :picture, :string
    add_column :tiles, :scene_description, :string
    add_column :tiles, :treasure_description, :string
    add_column :tiles, :monster_description, :string
    add_column :tiles, :visitor_id, :integer
  end
  def down
    remove_column :tiles, :picture
    remove_column :tiles, :scene_description
    remove_column :tiles, :treasure_description
    remove_column :tiles, :monster_description
    remove_column :tiles, :visitor_id
  end
end
