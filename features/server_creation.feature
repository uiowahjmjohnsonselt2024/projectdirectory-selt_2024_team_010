Feature: Server creation
  As a user
  I want to be able to create a server
  So that I can play the game with my friends

  Background:
    Given I have an account with the username "test_host", email "host@test.test" and password "abcdefghi"

  Scenario: Displaying the game list screen
    Given I log in with the username "test_host" and password "abcdefghi"

    When I am on the servers screen

    Then I should see a table
    And I should see a "Create New" button
    And I should see a "Add Existing" button

  Scenario: Creating a new game server
    Given I log in with the username "test_host" and password "abcdefghi"
    And I am on the servers screen

    When I click the "Create New" link
    And I create a server with the name "Server 1"

    Then I should see a server with the name "Server 1" and the host "test_host"