Given(/^I am on the servers screen$/) do
  visit games_path
end

And(/^I create a server with the name "([^"]*)"$/) do |name|
  fill_in('Server Name', with: name)
  click_button 'Create'
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