class AddPasswordResetToUsers < ActiveRecord::Migration
  def up
    add_column :users, :password_reset_token, :string
    add_column :users, :password_reset_sent_at, :datetime
  end

  def down
    remove_column :users, :password_reset_token, if_exists: true
    remove_column :users, :password_reset_sent_at, if_exists: true
  end
end
