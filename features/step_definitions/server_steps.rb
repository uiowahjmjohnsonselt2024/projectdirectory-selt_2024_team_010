Given(/^I am on the servers screen$/) do
  visit games_path
end

Given(/^A server with the name "([^"]*)" and host "([^"]*)" exists$/) do |name, host|
  test_host = User.find_by_username(host)
  test_host.games.create!(name: name, owner_id: test_host.id, max_user_count: 6)
end

When(/^I create a server with the name "([^"]*)"$/) do |name|
  fill_in('Server Name', with: name)
  click_button 'Create'
end

When(/^I search for a server with the name "([^"]*)"$/) do |name|
  fill_in('Server Name', with: name)
  click_button 'Search'
end

When(/^I add the server with the name "([^"]*)" and the host "([^"]*)"$/) do |name, host|
  page.all(:xpath, ".//tbody/tr").each do |tr|
    if tr.text.include?(name) and tr.text.include?(host)
      tr.click_on('Add')
      break
    end
  end
end

When(/^I join the server with the name "([^"]*)" and the host "([^"]*)"$/) do |name, host|
  page.all(:xpath, ".//tbody/tr").each do |tr|
    if tr.text.include?(name) and tr.text.include?(host)
      tr.click_on('Join')
      break
    end
  end
end

Then(/^I should see a server with the name "([^"]*)" and the host "([^"]*)"$/) do |name, host|
  exists = false
  page.all(:xpath, ".//tbody/tr").each do |tr|
    if tr.text.include?(name) and tr.text.include?(host)
      exists = true
      break
    end
  end
  expect(exists).to be true
end

Then(/^I should be on the servers screen$/) do
  expect(page.current_path).to eq('/games')
end

Then(/^I should be on the game screen for the game "([^"]*)"$/) do |name|
  game = Game.find_by_name(name)
  expect(page.current_path).to eq("/games/#{game.id}")
end