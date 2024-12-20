# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

User.destroy_all

# Create sample users
User.create!(
  username: 'testuser',
  email: 'test@test.com',
  password: 'password123',
  password_confirmation: 'password123',
  shard_amount: 100.5,
  money_usd: 2500.75,
  isAdmin: true
)

User.create!(
  username: 'bob',
  email: 'bob@test.com',
  password: 'securepass456',
  password_confirmation: 'securepass456',
  shard_amount: 300.0,
  money_usd: 1500.0
)
#
# Game.destroy_all
# Character.destroy_all
#
# test_user = User.find_by(username: 'bob')
#
# new_game = Game.create!(
#   owner_id: test_user.id,
#   name: "Test Server"
# )
#
# test_user.characters.create!(
#   game_id: new_game.id,
# )
