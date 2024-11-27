# Backgrounds:

Given /^I am on the dashboard screen$/ do
  visit dashboard_path
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