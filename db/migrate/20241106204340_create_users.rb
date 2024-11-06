class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.float :shard_amount
      t.float :money_usd

      t.timestamps
    end
  end
end
