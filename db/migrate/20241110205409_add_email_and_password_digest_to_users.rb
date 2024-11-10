class AddEmailAndPasswordDigestToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email, :string
    rename_column :users, :password, :password_digest
  end
end
