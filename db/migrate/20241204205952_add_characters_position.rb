class AddCharactersPosition < ActiveRecord::Migration
  def change
    add_column :characters, :x_position, :integer
    add_column :characters, :y_position, :integer
  end
end
