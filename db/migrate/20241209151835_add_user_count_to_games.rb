class AddUserCountToGames < ActiveRecord::Migration
  def up
    add_column :games, :max_user_count, :integer
  end
  def down
    remove_column :games, :max_user_count
  end
end
