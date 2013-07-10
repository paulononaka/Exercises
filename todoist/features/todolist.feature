Feature: To Do List Test Suite
  In order to be sure in ability to login, create and delete tasks
  As a tester
  So I want to run test for each step

  Background:
   Given I am on the To Do List website
   When I click on 'Login' link
   And I enter my email
   And I enter my password
   And I click on Login button

  Scenario: Login
    Then I should should see link 'Add project'

  Scenario: Create task
    And I click on 'My Tasks' link
    And I click on 'Add task' link
    And I enter 'New Task' as a task name
    And I enter: Due day is tommorow
    And I click the button 'Add Task'
    Then I should see task with name 'New Task'
    And I should see the date 'Tommorow'

  Scenario: Delete task
    And I click on 'My Tasks' link
    And I click on 'Add task' link
    And I enter 'New Task for delete' as a task name
    And I enter: Due day is tommorow
    And I click the button 'Add Task'
    And I call context menu on 'New Task' task
    And I choose 'Delete task' from menu
    Then I should not see task 'New Task for delete'