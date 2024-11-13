class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :session_token
      t.references :user
      t.timestamps null: false
    end
  end
end
