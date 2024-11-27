class AddUserToGames < ActiveRecord::Migration
  def change
    add_reference :games, :owner, foreign_key: { to_table: :users }
  end
end
