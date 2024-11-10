Feature: Login Screen
  As a registered user
  I want to log in
  So that I can access my account

  Background:
    Given I am on the login screen

  Scenario: Displaying the login screen
    Then I should see "Shards of the Grid"
    And I should see a login prompt

  Scenario: Logging in with valid credentials
    When I log in with the username "testuser" and password "password123"
    Then I should see "Login successful"
    And I should be on the main dashboard

  Scenario: Going back to the welcome screen
    When I click the "Back" button
    Then I should be on the welcome screen
