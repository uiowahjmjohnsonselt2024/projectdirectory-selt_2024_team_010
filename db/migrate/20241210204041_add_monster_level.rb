class AddMonsterLevel < ActiveRecord::Migration
  def up
    add_column :tiles, :monster_level, :integer
  end

  def down
    remove_column :tiles, :monster_level
  end
end
