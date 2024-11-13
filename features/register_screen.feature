Feature: Register Screen
  As a new user
  I want to register
  So that I can create an account

  Scenario: Displaying the register screen
    Given I am on the register screen
    And I should see a register prompt

  Scenario: Registering a new account
    Given I am on the register screen
    When I register with the username "testuser", email "testuser@test.test", and password "password123"
    Then I should be on the main dashboard

  Scenario: Going back to the welcome screen
    Given I am on the register screen
    When I click the "Back" link
    Then I should be on the welcome screen
