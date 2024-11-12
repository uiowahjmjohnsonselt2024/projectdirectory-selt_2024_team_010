Given(/^I am on the login screen$/) do
  visit login_path
end

Given(/^I have an account with the username "([^"]*)", email "([^"]*)" and password "([^"]*)"$/) do |username, email, password|
  User.create!(username: username, email: email, password: password, password_confirmation: password)
  expect(User.where(username: username)).not_to eq(nil)
end

When(/^I log in with the username "([^"]*)" and password "([^"]*)"$/) do |username, password|
  fill_in('Username', with: username)
  fill_in('Password', with: password)
  click_button('Login')
end

When(/^I click the "([^"]*)" button$/) do |button|
  click_button(button)
end

When(/^I click the "([^"]*)" link$/) do |link|
  click_link(link)
end

Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content text
end

Then(/^I should see a login prompt$/) do
  expect(page).to have_field 'Username'
  expect(page).to have_field 'Password'
  expect(page).to have_button 'Login'
  expect(page).to have_link 'Back'
end

Then(/^I should be on the main dashboard$/) do
  expect(page.current_path).to eq('/dashboard')
end

Then(/^I should be on the welcome screen$/) do
  expect(page.current_path).to eq('/welcome')
end

Then(/^I should be on the login screen$/) do
  expect(page.current_path).to eq('/login')
end