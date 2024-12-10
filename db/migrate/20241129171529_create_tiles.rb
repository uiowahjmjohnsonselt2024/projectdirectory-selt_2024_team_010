class CreateTiles < ActiveRecord::Migration
  def up
    create_table :tiles do |t|
      t.references :game
      t.integer :x_position
      t.integer :y_position
      t.string :biome
    end
  end
  def down
    drop_table :tiles
  end
end
