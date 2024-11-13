Feature: Welcome Screen
  As a new user
  I want to see a welcome screen
  So that I can choose to log in or register

  Scenario: Displaying the welcome screen
    Given I am on the welcome screen
    Then I should see "Shards of the Grid"
<<<<<<< HEAD
    And I should see a "Login" button
    And I should see a "Register" button
=======
    And I should see "Welcome!"
    And I should see a "Login" link
    And I should see a "Register" link
>>>>>>> main

  Scenario: Navigating to the login screen
    Given I am on the welcome screen
    When I click the "Login" link
    Then I should be on the login screen

  Scenario: Navigating to the register screen
    Given I am on the welcome screen
    When I click the "Register" link
    Then I should be on the register screen
