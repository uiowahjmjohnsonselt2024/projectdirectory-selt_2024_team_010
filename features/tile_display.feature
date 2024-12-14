Feature: Tile Grid Display
  As a user
  I want to have a display of all the tiles
  So that I know what tiles I can move to

  Background:
    Given I have an account with the username "test1", email "test1@test.test" and password "password123"
    And I have an account with the username "test2", email "test2@test.test" and password "password123"
    And A server with the name "server1" and host "test1" exists
    And User "test2" has added server "server1" with host "test1"

  Scenario: Show the grid from the host
    Given I log in with the username "test1" and password "password123"
    And I am on the servers screen

    When I join the server with the name "server1" and the host "test1"

    Then I should see 49 tiles in a grid
    And I should see the movement buttons

  Scenario: Show the grid from a joining user
    Given I log in with the username "test2" and password "password123"
    And I am on the servers screen

    When I join the server with the name "server1" and the host "test1"

    Then I should see 49 tiles in a grid
    And I should see the movement buttons