class CreateChat < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.references :game
      t.datetime :time_sent
      t.string :user
      t.string :message
    end
  end
end
