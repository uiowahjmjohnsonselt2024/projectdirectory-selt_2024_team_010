class ChangeRecentCharacterToIntegerInUsers < ActiveRecord::Migration
  def change
    change_column :users, :recent_character, :integer
  end
end
