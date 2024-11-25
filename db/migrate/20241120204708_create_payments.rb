class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.float :money_usd
      t.string :currency
      t.timestamps
      t.references :user, :null=>false, foreign_key: true
    end
  end
end
