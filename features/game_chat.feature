Feature: Game Chat
  As a user
  I want to be able to send and receive messages
  So that I can communicate with my friends in the game

  Background:
    Given I have an account with the username "test1", email "test1@test.test" and password "password123"
    And I have an account with the username "test2", email "test2@test.test" and password "password123"
    And A server with the name "server1" and host "test1" exists
    And User "test2" has added server "server1" with host "test1"

  Scenario: Displaying the chat box
    Given I log in with the username "test1" and password "password123"
    And I am on the servers screen

    When I join the server with the name "server1" and the host "test1"

    Then I should be on the game screen for the game "server1"
    And I should see a chat box
    And I should see a place to enter a message