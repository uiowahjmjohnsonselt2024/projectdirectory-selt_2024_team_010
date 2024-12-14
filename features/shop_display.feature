Feature: Shop, Item, and Tile tabs
  As a user
  I want to be able to see the shop, the tile details, and my items
  So that I can manage my character's inventory

  Background:
    Given I have an account with the username "test1", email "test1@test.test" and password "password123"
    And A server with the name "server1" and host "test1" exists
    And I log in with the username "test1" and password "password123"
    And I am on the servers screen

  Scenario: Displaying the tab selectors
    When I join the server with the name "server1" and the host "test1"

    Then I should see a "Shop" tab
    And I should see an "Items" tab
    And I should see a "Tile" tab

  Scenario: Displaying the Shop tab
    When I join the server with the name "server1" and the host "test1"
    And I go to the "Shop" tab

    Then I should see a shop tab for "Weapons"
    And I should see a shop tab for "Armor"
    And I should see a shop tab for "Abilities"
    And I should see a shop tab for "Healing"
    And I should see a "Refresh : 500 Shards" button

  Scenario: Displaying the Items tab
    When I join the server with the name "server1" and the host "test1"
    And I go to the "Items" tab

    Then I should see "Your Items"

  Scenario: Displaying the Tiles tab
    When I join the server with the name "server1" and the host "test1"
    And I go to the "Tile" tab

    Then The tile container should exist