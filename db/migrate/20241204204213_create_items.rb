class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :type
      t.string :name
      t.string :description
      t.integer :level
      t.references :character
    end
  end
end
