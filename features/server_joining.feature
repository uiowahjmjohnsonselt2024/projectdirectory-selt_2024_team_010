Feature: Server joining
  As a user
  I want to be able to find other people's servers
  So that I can join my friend's game

  Background:
    Given I have an account with the username "test_host", email "host@test.test" and password "abcdefghi"
    And I have an account with the username "test_client", email "client@test.test" and password "abcdefghi"
    And A server with the name "Server 1" and host "test_host" exists

  Scenario: Finding a game server
    Given I log in with the username "test_client" and password "abcdefghi"
    And I am on the servers screen

    When I click the "Add Existing" link
    And I search for a server with the name "Server 1"

    Then I should see a server with the name "Server 1" and the host "test_host"
    When I add the server with the name "Server 1" and the host "test_host"

    Then I should be on the servers screen
    And I should see a server with the name "Server 1" and the host "test_host"

  Scenario: Joining a game server
    Given I log in with the username "test_client" and password "abcdefghi"
    And I am on the servers screen
    And I click the "Add Existing" link
    And I search for a server with the name "Server 1"
    And I add the server with the name "Server 1" and the host "test_host"

    When I join the server with the name "Server 1" and the host "test_host"
    Then I should be on the game screen for the game "Server 1"
