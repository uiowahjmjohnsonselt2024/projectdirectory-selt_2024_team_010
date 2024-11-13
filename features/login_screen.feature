Feature: Login Screen
  As a registered user
  I want to log in
  So that I can access my account

  Background:
    Given I am on the login screen
    And I have an account with the username "testuser", email "testuser@test.test" and password "password123"

  Scenario: Displaying the login screen
    Then I should see a login prompt

  Scenario: Logging in with valid credentials
    When I log in with the username "testuser" and password "password123"
    Then I should be on the main dashboard
    
  Scenario: Logging in with invalid credentials
    When I log in with the username "fake" and password "fake"
    Then I should be on the login screen
    And I should see "Invalid username or password"

  Scenario: Going back to the welcome screen
    When I click the "Back" link
    Then I should be on the welcome screen
