class UpdateUsersTable < ActiveRecord::Migration
  def change
    remove_column :users, :session, :string # Remove the session column
    add_column :users, :isAdmin, :boolean, default: false # Add the isAdmin column with a default value of false
    change_column_default :users, :money_usd, 0 # Set default value for money_usd
    change_column_default :users, :shard_amount, 0 # Set default value for shard_amount
  end
end
