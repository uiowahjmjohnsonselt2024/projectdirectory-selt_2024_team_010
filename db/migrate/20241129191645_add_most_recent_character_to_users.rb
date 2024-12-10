# This was going to use a "belongs_to" relationship, however the optional flag was only added in rails 5.0, and we are
# using rails 4.2.10. Therefore we have no option but to manually control the reference here.
class AddMostRecentCharacterToUsers < ActiveRecord::Migration
  def up
    add_column :users, :recent_character, :string
  end
  def down
    remove_column :users, :recent_character
  end
end
