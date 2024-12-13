class AddDefaultValuesToCharacters < ActiveRecord::Migration
  def change
    change_column_default :characters, :x_position, 0
    change_column_default :characters, :y_position, 0
  end
end
