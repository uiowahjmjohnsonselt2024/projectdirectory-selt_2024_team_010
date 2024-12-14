Then(/^I should see (\d+) tiles in a grid$/) do |number|
  expect(page).to have_css('.content', count: number)
end

Then(/^I should see the movement buttons$/) do
  expect(page).to have_button(class: 'move-button move-up')
  expect(page).to have_button(class: 'move-button move-down')
  expect(page).to have_button(class: 'move-button move-left')
  expect(page).to have_button(class: 'move-button move-right')
end