require "watir-webdriver"
require "rspec-expectations"
require 'win32ole'

browser = Watir::Browser.new :firefox
browser.driver.manage.timeouts.implicit_wait = 5

ai = WIN32OLE.new("AutoItX3.Control")

url = "http://crm.zoho.com/crm/login.sas"

browser.goto url

browser.link(:href, "/crm/lp/login.html").click
browser.frame(:id, "zohoiam").text_field(:id=>"lid").set("dima@voin.us")
browser.frame(:id, "zohoiam").text_field(:id, "pwd").set("Ci8ili3a&ion")
browser.frame(:id, "zohoiam").button(:id, "submit_but").fire_event('onclick')

accounts = browser.link(:id, "tab_Accounts")
accounts.wait_until_present
accounts.click

new_account = browser.button(:value, "New Account")
new_account.wait_until_present

new_account.click

browser.text_field(:id, "property(Account Name)").set("Test Account #01")
browser.text_field(:id, "property(Phone)").set("415-236-0046")
browser.image(:src, "//img.zohostatic.com/crm/images/spacer.gif").click

browser.windows.last.use
browser.link(:text, "Parent Account").click



browser.windows.first.use
browser.select_list(:name, "property(Account Type)").select_value("Analyst")
browser.select_list(:name, "property(Industry)").select_value("ASP")

browser.text_field(:id,"property(Billing Street)").set("101 Main St.")
browser.text_field(:id,"property(Billing City)").set("San Francisco")
browser.text_field(:id,"property(Billing State)").set("CA")
browser.text_field(:id,"property(Billing Code)").set("94102")
browser.text_field(:id,"property(Billing Country)").set("USA")

browser.text_field(:id,"property(Shipping Street)").set("101 Main St.")
browser.text_field(:id,"property(Shipping City)").set("San Francisco")
browser.text_field(:id,"property(Shipping State)").set("CA")
browser.text_field(:id,"property(Shipping Code)").set("94102")
browser.text_field(:id,"property(Shipping Country)").set("USA")

browser.text_field(:id,"property(Description)").set("This is a test description")

browser.button(:value, "Save").click
sleep 2
accounts = browser.link(:id, "tab_Accounts")
accounts.wait_until_present
accounts.click

account = browser.link(:text, "Test Account #01")
account.wait_until_present
account.click


puts "PASS" if browser.span(:id,"value_Account Name").text ==  "Test Account #01"
puts "PASS" if browser.span(:id,"subvalue_Phone").text ==  "415-236-0046"
puts "PASS" if browser.link(:id,"subvalue_Parent Account").text ==  "Parent Account"
puts "PASS" if browser.span(:id,"value_Account Type").text ==  "Analyst"
puts "PASS" if browser.span(:id,"value_Industry").text ==  "ASP"
puts "PASS" if browser.span(:id,"value_Billing Street").text ==  "101 Main St."
puts "PASS" if browser.span(:id,"value_Billing City").text ==  "San Francisco"
puts "PASS" if browser.span(:id,"value_Billing State").text ==  "CA"
puts "PASS" if browser.span(:id,"value_Billing Code").text ==  "94102"
puts "PASS" if browser.span(:id,"value_Billing Country").text ==  "USA"
puts "PASS" if browser.span(:id,"value_Shipping Street").text ==  "101 Main St."
puts "PASS" if browser.span(:id,"value_Shipping City").text ==  "San Francisco"
puts "PASS" if browser.span(:id,"value_Shipping State").text ==  "CA"
puts "PASS" if browser.span(:id,"value_Shipping Code").text ==  "94102"
puts "PASS" if browser.span(:id,"value_Shipping Country").text ==  "USA"
puts "PASS" if browser.pre(:id,"value_Description").text ==  "This is a test description"


accounts = browser.link(:id, "tab_Accounts")
accounts.wait_until_present
accounts.click

new_account = browser.button(:value, "New Account")
new_account.wait_until_present
new_account.click

browser.button(:value, "Save").click

puts "ALERT PASS" if browser.alert.text == "Account Name cannot be empty"
browser.alert.ok

browser.link(:text, "Setup").click
browser.div(:text, "Data Administration").fire_event('onclick')
browser.link(:text, "Export Data").click
sleep 2
browser.select_list(:name, "module").select_value("Accounts")
browser.button(:id, "Submit").click

browser.alert.ok

ai.WinWait("Opening", "", 5)

file_name = ai.WinGetTitle("[active]").split(" ").last.to_s
puts file_name

ai.Send("{DOWN}")
ai.Send ("{ENTER}")

browser.link(:text, "Migrate from other CRM").click
browser.select_list(:name, "module").select_value("Accounts")
browser.button(:value, "Next").click

browser.file_field(:name, "theFile").set(File.join(ENV['HOME'],"Downloads","#{file_name}"))
browser.button(:value, "Next").click

browser.select_list(:id,"CrmAccount:ACCOUNTNAME").select("Account Name( Col: 5)")
browser.button(:id,"importSubmit").click

import = browser.button(:id,"importSubmit")
import.wait_until_present
import.click

browser.close