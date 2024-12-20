Given(/^I am on the login screen$/) do
  visit login_path
end

Given(/^I am on the welcome screen$/) do
  visit welcome_path
end

Given(/^I am on the register screen$/) do
  visit register_path
end

Given(/^I have an account with the username "([^"]*)", email "([^"]*)" and password "([^"]*)"$/) do |username, email, password|
  User.create!(username: username, email: email, password: password, password_confirmation: password)
  expect(User.where(username: username)).not_to eq(nil)
end

When(/^I log in with the username "([^"]*)" and password "([^"]*)"$/) do |username, password|
  visit login_path
  fill_in('username', with: username)
  fill_in('password', with: password)
  click_button('Login')
end

Then(/^I should see a login prompt$/) do
  expect(page).to have_field 'Username'
  expect(page).to have_field 'Password'
  expect(page).to have_button 'Login'
  expect(page).to have_link 'Back'
end

Then(/^I should be on the welcome screen$/) do
  expect(page.current_path).to eq('/welcome')
end

Then(/^I should be on the login screen$/) do
  expect(page.current_path).to eq('/login')
end
Then(/^I should be on the register screen$/) do
  expect(page.current_path).to eq('/register')
end

And(/^I should see a "([^"]*)" link$/) do |link|
  expect(page).to have_link(link)
end

And(/^I should see a register prompt$/) do
  expect(page).to have_field 'Username'
  expect(page).to have_field 'Email'
  expect(page).to have_field 'Password'
  expect(page).to have_field 'Confirm Password'
  expect(page).to have_link 'Back'
end

When(/^I register with the username "([^"]*)", email "([^"]*)", and password "([^"]*)"$/) do |username, email, password|
  fill_in 'Username', with: username
  fill_in 'Email', with: email
  fill_in 'Password', with: password
  fill_in 'Confirm Password', with: password
  click_button 'Register'
end