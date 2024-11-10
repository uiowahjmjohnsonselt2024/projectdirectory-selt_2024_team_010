class RecreateUsersTable < ActiveRecord::Migration
  def up
    drop_table :users

    create_table :users do |t|
      t.string   :username
      t.string   :email
      t.string   :password_digest
      t.float    :shard_amount
      t.float    :money_usd
      t.datetime :created_at
      t.datetime :updated_at
    end
  end

  def down
    create_table :users do |t|
      t.string   :username
      t.string   :password_digest
      t.float    :shard_amount
      t.float    :money_usd
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :email
    end
  end
end
