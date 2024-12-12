# Actions:
When(/^I send the message "([^"]*)" to the chat$/) do |message|
  fill_in('message_input', with: message)
  click_button('Submit')
end

And(/^I wait for the chat to refresh$/) do # Well that is unfortunate, Selenium does not support this.
  page.execute_script('updateChat()')
end

# Expectations:
Then(/^I should see a chat box$/) do
  expect(page).to have_xpath("//div[@class='chat-messages']")
end

Then(/^I should see a place to enter a message$/) do
  expect(page.find('.chat-container')).to have_field('message_input')
  expect(page.find('.chat-container')).to have_button('Submit')
end

Then(/^The message field should be empty$/) do
  expect(page.find_field('message_input')).to have_text('')
end

Then(/^The chat box should contain the message "([^"]*)"$/) do |message|
  expect(page.find('.chat-messages')).to have_content(message)
end