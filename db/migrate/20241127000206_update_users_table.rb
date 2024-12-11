class UpdateUsersTable < ActiveRecord::Migration
  def up
    remove_column :users, :session, :string if column_exists?(:users, :session) # Remove the session column if it exists
    add_column :users, :isAdmin, :boolean, default: false unless column_exists?(:users, :isAdmin) # Add the isAdmin column with a default value of false
    change_column_default :users, :money_usd, 0 # Set default value for money_usd
    change_column_default :users, :shard_amount, 0 # Set default value for shard_amount
  end

  def down
    add_column :users, :session, :string unless column_exists?(:users, :session) # Add back the session column
    remove_column :users, :isAdmin if column_exists?(:users, :isAdmin) # Remove the isAdmin column
    change_column_default :users, :money_usd, nil # Remove default value for money_usd
    change_column_default :users, :shard_amount, nil # Remove default value for shard_amount
  end
end
