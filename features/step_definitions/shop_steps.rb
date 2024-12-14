# Actions
When(/^I go to the "([^"]*)" tab$/) do |tab|
  click_button(tab)
end

# Expectations
Then(/^I should see an? "([^"]*)" tab$/) do |tab|
  expect(page.find('.main-tabs')).to have_button(tab)
end

Then(/^I should see a shop tab for "([^"]*)"$/) do |tab|
  expect(page.find(id: 'ShopSection')).to have_button(tab)
end

# I don't really have a better way to test this unfortunately
Then(/^The tile container should exist$/) do
  print page.html
  expect(page).to have_xpath('.//div[@id="GameSection"]')
end