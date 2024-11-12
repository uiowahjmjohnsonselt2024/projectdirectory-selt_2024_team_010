class AddSessionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :session, :string # session key in users table of type string
  end
end
