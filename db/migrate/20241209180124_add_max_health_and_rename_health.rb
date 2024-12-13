class AddMaxHealthAndRenameHealth < ActiveRecord::Migration
  def change
    # Rename the 'health' column to 'currentHealth'
    rename_column :characters, :health, :currentHealth

    # Add the 'maxHealth' column with a default value of 10
    add_column :characters, :maxHealth, :integer, default: 10
  end
end
