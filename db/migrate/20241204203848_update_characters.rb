class UpdateCharacters < ActiveRecord::Migration
  def change
    add_column :characters, :level, :integer, default: 1
    add_column :characters, :health, :integer, default: 5
  end
end
