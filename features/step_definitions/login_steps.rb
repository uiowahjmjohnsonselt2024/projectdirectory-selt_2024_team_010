Given(/^I am on the login screen$/) do
  visit login_path
end

When(/^I log in with the username "([^"]*)" and password "([^"]*)"$/) do |username, password|
  fill_in('Username', with: username)
  fill_in('Password', with: password)
  click_button('Login')
end

When(/^I click the "([^"]*)" button$/) do |button|
  click_button(button)
end

Then(/^I should see "([^"]*)"$/) do |text|
  expect(page).to have_content text
end

Then(/^I should see a login prompt$/) do
  expect(page).to have_field 'Username'
  expect(page).to have_field 'Password'
  expect(page).to have_button 'Login'
  expect(page).to have_button 'Back'
end

Then(/^I should be on the main dashboard$/) do
  expect(page.current_path).to eq('/dashboard')
end

Then(/^I should be on the welcome screen$/) do
  expect(page.current_path).to eq('/welcome')
end