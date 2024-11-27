class CreateCharacters < ActiveRecord::Migration
  def up
    create_table :characters do |t|
      t.references :user
      t.references :game
    end
  end
  def down
    drop_table :characters
  end
end
