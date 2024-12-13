# Backgrounds:

Given /^I am on the dashboard screen$/ do
  visit dashboard_path
end

Given /^User "([^"]*)" has added server "([^"]*)" with host "([^"]*)"$/ do |username, server, host|
  user = User.find_by_username(username)
  game = Game.find_by(name: server, owner_id: User.find_by_username(host).id)
  user.characters.create!(game_id: game.id)
end

# Actions:

When(/^I click the "([^"]*)" button$/) do |button|
  click_button button
end

When(/^I click the "([^"]*)" link$/) do |link|
  click_link link
end

# Expectations:

Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content text
end

Then(/^I should be on the main dashboard$/) do
  expect(page.current_path).to eq('/dashboard')
end

Then(/^I should see a "([^"]*)" button$/) do |button|
  expect(page.has_button?(button)||page.has_link?(button)).to eq true
  # Many "Buttons" are links with the "btn" CSS class, so I have to check for either.
end

Then(/^I should see a table$/) do
  expect(page).to have_table
end