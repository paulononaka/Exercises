Given /^I am on the To Do List website$/ do
  @browser.goto "http://todoist.com"
end

When(/^I click on 'Login' link$/) do
  @browser.link(:text, "Login").click
end

And(/^I enter my email$/) do
  email = @browser.frame(:name, "GB_frame").frame(:id,"GB_frame").text_field(:id, "email")
  email.wait_until_present
  email.set("dima@voin.us")
end

And(/^I enter my password$/) do
  @browser.frame(:name, "GB_frame").frame(:id,"GB_frame").text_field(:id, "password").set("12345678")
end

 And(/^I click on Login button$/) do
   @browser.frame(:name, "GB_frame").frame(:id,"GB_frame").link(:text, "Login").click
 end

Then(/^I should should see link 'Add project'$/) do
  add_project = @browser.div(:id,"project_man").link(:text,"Add project")
  add_project.wait_until_present
  add_project.should exist
end

And(/^I click on 'My Tasks' link$/) do
  my_task = @browser.td(:class, "name")
  my_task.wait_until_present
  my_task.click
end

And(/^I click on 'Add task' link$/) do
  @browser.link(:text, "Add task").click
end

And(/^I enter 'New Task' as a task name$/) do
 @browser.text_field(:name, "ta").set("New task")
end

And(/^I enter 'New Task for delete' as a task name$/) do
  @browser.text_field(:name, "ta").set("New Task for delete")
end

And(/^I enter: Due day is tommorow$/) do
 @browser.text_field(:name,"due_date").click
 day = Time.at(Time.now.to_i + 86400).day
 @browser.td(:text,"#{day}").click
end

And(/^I click the button 'Add Task'$/) do
  @browser.span(:text,"Add task").click
end

Then(/^I should see task with name 'New Task'$/) do
  @browser.span(:class, "text").text.should include "New task"
end

And(/^I should see the date 'Tommorow'$/) do
  @browser.span(:class,"date date_future date_tom").text.should include "Tomorrow"
end

And(/^I call context menu on 'New Task' task$/) do
  @browser.span(:class, "text").fire_event("oncontextmenu")
end

And(/^I choose 'Delete task' from menu$/) do
  @browser.div(:text, "Delete task").click
end

Then(/^I should not see task 'New Task for delete'$/) do
  @browser.span(:class, "text").should_not exist
end