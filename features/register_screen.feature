Feature: Register Screen
  As a new user
  I want to register
  So that I can create an account

  Scenario: Displaying the register screen
    Given I am on the register screen
    Then I should see "Shards of the Grid"
    And I should see a "Username" field
    And I should see a "Password" field
    And I should see a "Confirm Password" field
    And I should see a "Register" button
    And I should see a "Back" button

  Scenario: Registering a new account
    Given I am on the register screen
    When I fill in "Username" with "testuser"
    And I fill in "Password" with "password123"
    And I fill in "Confirm Password" with "password123"
    And I click the "Register" button
    Then I should see a message "Registration successful"

  Scenario: Going back to the welcome screen
    Given I am on the register screen
    When I click the "Back" button
    Then I should be on the welcome screen
