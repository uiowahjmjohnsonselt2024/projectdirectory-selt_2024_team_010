Feature: Login Screen
  As a registered user
  I want to log in
  So that I can access my account

  Scenario: Displaying the login screen
    Given I am on the login screen
    Then I should see "Shards of the Grid"
    And I should see a "Username" field
    And I should see a "Password" field
    And I should see a "Login" button
    And I should see a "Back" button

  Scenario: Logging in with valid credentials
    Given I am on the login screen
    When I fill in "Username" with "testuser"
    And I fill in "Password" with "password123"
    And I click the "Login" button
    Then I should see a message "Login successful"
    And I should be on the main dashboard

  Scenario: Going back to the welcome screen
    Given I am on the login screen
    When I click the "Back" button
    Then I should be on the welcome screen
