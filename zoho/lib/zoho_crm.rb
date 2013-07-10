require "watir-webdriver"
require 'win32ole'
require_relative 'test_report_writer'
include TestReportWriter
require_relative 'test_spec'
require 'json'
require 'trollop'

class ZohoCRM
  attr_accessor :test_spec_path,                
                :verbose,
                :debug

  def initialize(test_spec_path)
    ts = TestSpec.new(test_spec_path)
    @input = ts.test_spec
    @report ={}
    @report[:verification] = {}
    @report[:title] = @input["title"]
    @verbose ||= false
    @debug ||= false
    @element_number = 1
    @report[:start_time] = Time.now
  end

  def start_test
    @browser = Watir::Browser.new :firefox
    @browser.driver.manage.timeouts.implicit_wait = 5
    @browser.goto @input["main_url"]
  end

  def puts_debug_message(message)
    $stderr.puts("DEBUG: #{message}") if @debug
  end

  def puts_verbose_message(message)
    $stdout.puts("#{message}") if @verbose
  end

  def fail_result(element_number,ew)
    @report[:verification]["#{element_number}"][:result] = "FAIL"
    @report[:verification]["#{element_number}"][:result_message] = "While getting environment credentials: #{ew.message}"

    puts_verbose_message("Error in method fail_result:#{ew.message}")
  end

  def block_result(element_number,e)
    @report[:verification]["#{element_number}"][:result] = "BLOCK"
    @report[:verification]["#{element_number}"][:result_message] = "While getting environment credentials: #{e.message}"

    puts_verbose_message("Error in method block_result:#{e.message}")
  end

  def pass_result(element_number)
    if element_number == nil
      @report[:verification]["#{@element_number}"][:result] = "PASS"
      @element_number += 1
    else
      @report[:verification]["#{element_number}"][:result] = "PASS"
    end
  end

  def create_hash
    uri_re = /(https?):\/\/([0-9a-zA-Z][-\w]*[0-9a-zA-Z]\.)+[a-zA-Z]{2,9}([\w\/.]*)/
    @report[:verification]["#{@element_number}"] = {}
    @report[:verification]["#{@element_number}"][:page_url] = @browser.url.match(uri_re).to_s
  end

  def verification(element, action)

    begin
      create_hash
      element_number = @element_number
      element.wait_until_present
      element_class = element.class.to_s.split("::").last.to_s.gsub("Anchor","Link").gsub("Div","Button")
      @report[:verification]["#{element_number}"][:element] = "Element verification: #{element_class} '#{element.text}'"

      puts_debug_message("Element number #{@element_number} and report: #{@report[:verification]}")

      case action
        when "click"
          element.click
        when "fire"
          element.fire_event('onclick')
      end

      pass_result(nil)

      rescue Watir::Exception::UnknownObjectException => we
        fail_result(element_number,we)
      rescue Exception => e
        block_result(element_number,e)
    end

  end

  def login
    begin
      verification(@browser.link(:href, "/crm/lp/login.html"),"click")

      create_hash
      element_number = @element_number
      @element_number += 1
      @report[:verification]["#{element_number}"][:element] =  "Action: Login verification"
      @browser.frame(:id, "zohoiam").text_field(:id=>"lid").set(@input["login_page"]["username"])
      @browser.frame(:id, "zohoiam").text_field(:id, "pwd").set(@input["login_page"]["password"])

      verification(@browser.frame(:id, "zohoiam").button(:id, "submit_but"),"fire")


      pass_result(element_number)

      rescue Watir::Exception::UnknownObjectException => we
        fail_result(element_number,we)
      rescue Exception => e
        block_result(element_number,e)
    end
  end

  def create_account
    begin
      verification(@browser.link(:id, "tab_Accounts"),"click")
      verification(@browser.button(:value, "New Account"),"click")

      create_hash
      element_number = @element_number
      @element_number += 1
      @report[:verification]["#{element_number}"][:element] =  "Action: Account creation"

      @browser.text_field(:id, "property(Account Name)").set(@input["account_page"]["account_name"])
      @browser.text_field(:id, "property(Phone)").set(@input["account_page"]["phone"])

      verification(@browser.image(:src, "//img.zohostatic.com/crm/images/spacer.gif"),"click")

      @browser.windows.last.use

      verification(@browser.link(:text, "#{@input["account_page"]["parent account"]}"),"click")

      @browser.windows.first.use
      @browser.select_list(:name,"property(Account Type)").select_value(@input["account_page"]["account_type"])
      @browser.select_list(:name,"property(Industry)").select_value(@input["account_page"]["industry"])
      @browser.text_field(:id,"property(Billing Street)").set(@input["account_page"]["billing_street"])
      @browser.text_field(:id,"property(Billing City)").set(@input["account_page"]["billing_city"])
      @browser.text_field(:id,"property(Billing State)").set(@input["account_page"]["billing_state"])
      @browser.text_field(:id,"property(Billing Code)").set(@input["account_page"]["billing_code"])
      @browser.text_field(:id,"property(Billing Country)").set(@input["account_page"]["billing_country"])
      @browser.text_field(:id,"property(Shipping Street)").set(@input["account_page"]["shipping_street"])
      @browser.text_field(:id,"property(Shipping City)").set(@input["account_page"]["shipping_city"])
      @browser.text_field(:id,"property(Shipping State)").set(@input["account_page"]["shipping_state"])
      @browser.text_field(:id,"property(Shipping Code)").set(@input["account_page"]["shipping_code"])
      @browser.text_field(:id,"property(Shipping Country)").set(@input["account_page"]["shipping_country"])
      @browser.text_field(:id,"property(Description)").set(@input["account_page"]["description"])

      verification(@browser.button(:value, "Save"),"click")

      pass_result(element_number)

      rescue Watir::Exception::UnknownObjectException => we
        fail_result(element_number,we)
      rescue Exception => e
        block_result(element_number,e)
    end
  end

  def alert_verification(element, expected_result)
    begin
      element_number = @element_number

      puts_debug_message("Alert verification: Element# #{element_number},Alert : #{element}  and expected result: {expected_result}")

      if element == expected_result
        @browser.alert.ok
        create_hash
        @report[:verification]["#{element_number}"][:element] = "Alert Verification"
        pass_result(element_number)
      else
        @browser.alert.ok
        create_hash
        @report[:verification]["#{element_number}"][:element] = "Alert Verification"
        @report[:verification]["#{element_number}"][:result] = "FAIL"
      end

      @element_number += 1

      rescue Watir::Exception::UnknownObjectException => we
        fail_result(element_number,we)
      rescue Exception => e
        block_result(element_number,e)
    end

    @report[:verification]["#{element_number}"][:result]

  end

  def field_verification(element, expected_result)
    begin
      create_hash
      element_number = @element_number
      @element_number += 1
      @report[:verification]["#{element_number}"][:element] =  "Field '#{element.to_s.scan(/[A-Z][a-z]+/).join(" ").to_s}' Verification"

      puts_debug_message("Field verification: Element# #{element_number},Alert : #{element}  and expected result: {expected_result}")

      if eval(element.gsub("'","")).text == expected_result
        pass_result(element_number)
      else
        @report[:verification]["#{element_number}"][:result] = "FAIL"
      end

      rescue Watir::Exception::UnknownObjectException => we
        fail_result(element_number,we)
      rescue Exception => e
        block_result(element_number,e)
    end

    @report[:verification]["#{element_number}"][:result]

  end

  def account_verification
    begin
      verification(@browser.link(:id, "tab_Accounts"),"click")
      verification(@browser.link(:text, "Test Account #01"),"click")

      create_hash
      element_number = @element_number
      @element_number += 1
      @report[:verification]["#{element_number}"][:element] =  "Action: Account Verification"

      res = []
      res << field_verification('@browser.span(:id,"value_Account Name")', @input["account_page"]["account_name"])
      res << field_verification('@browser.span(:id,"subvalue_Phone")', @input["account_page"]["phone"])
      res << field_verification('@browser.link(:id,"subvalue_Parent Account")', @input["account_page"]["parent account"])
      res << field_verification('@browser.span(:id,"value_Account Type")', @input["account_page"]["account_type"])
      res << field_verification('@browser.span(:id,"value_Industry")', @input["account_page"]["industry"])
      res << field_verification('@browser.span(:id,"value_Billing Street")', @input["account_page"]["billing_street"])
      res << field_verification('@browser.span(:id,"value_Billing City")', @input["account_page"]["billing_city"])
      res << field_verification('@browser.span(:id,"value_Billing State")', @input["account_page"]["billing_state"])
      res << field_verification('@browser.span(:id,"value_Billing Code")', @input["account_page"]["billing_code"])
      res << field_verification('@browser.span(:id,"value_Billing Country")',  @input["account_page"]["billing_country"])
      res << field_verification('@browser.span(:id,"value_Shipping Street")', @input["account_page"]["shipping_street"])
      res << field_verification('@browser.span(:id,"value_Shipping City")', @input["account_page"]["shipping_city"])
      res << field_verification('@browser.span(:id,"value_Shipping State")', @input["account_page"]["shipping_state"])
      res << field_verification('@browser.span(:id,"value_Shipping Code")', @input["account_page"]["shipping_code"])
      res << field_verification('@browser.span(:id,"value_Shipping Country")', @input["account_page"]["shipping_country"])
      res << field_verification('@browser.pre(:id,"value_Description")', @input["account_page"]["description"])

      puts_debug_message("Account verification results: #{res} ")

      if res.include?("BLOCK")
        @report[:verification]["#{element_number}"][:result] = "BLOCK"
      elsif res.include?("FAIL")
        @report[:verification]["#{element_number}"][:result] = "FAIL"
      else
        pass_result(element_number)
      end

    end
  end

  def blank_account_verification
    begin
      verification(@browser.link(:id, "tab_Accounts"),"click")
      verification(@browser.button(:value, "New Account"),"click")

      create_hash
      element_number = @element_number
      @element_number += 1
      @report[:verification]["#{element_number}"][:element] =  "Action: Blank Account creation"

      verification(@browser.button(:value, "Save"),"click")

      alert = alert_verification(@browser.alert.text, @input["blank_account_alert"])

      if alert == "BLOCK"
        @report[:verification]["#{element_number}"][:result] = "BLOCK"
      elsif alert == "FAIL"
        @report[:verification]["#{element_number}"][:result] = "FAIL"
      else
        pass_result(element_number)
      end

      rescue Watir::Exception::UnknownObjectException => we
        fail_result(element_number,we)
      rescue Exception => e
        block_result(element_number,e)
    end
  end

  def file_export
    begin
      verification(@browser.link(:text, "Setup"),"click")
      verification(@browser.div(:text, "Data Administration"),"fire")
      verification(@browser.link(:text, "Export Data"),"click")

      create_hash
      element_number = @element_number
      @element_number += 1
      @report[:verification]["#{element_number}"][:element] =  "Action: Export Accounts"
      @browser.select_list(:name, "module").select_value("Accounts")
      verification(@browser.button(:id, "Submit"),"click")
      @browser.alert.ok
      download_window = WIN32OLE.new("AutoItX3.Control")
      download_window.WinWait("Opening", "", 5)
      @file_name = download_window.WinGetTitle("[active]").split(" ").last.to_s

      puts_debug_message("Exported file name: #{@file_name}")

      download_window.Send("{DOWN}")
      download_window.Send ("{ENTER}")

      pass_result(element_number)

      rescue Watir::Exception::UnknownObjectException => we
        fail_result(element_number,we)
      rescue Exception => e
        block_result(element_number,e)
    end
  end

  def file_import
    begin
      verification(@browser.link(:text, "Migrate from other CRM"),"click")
      @browser.select_list(:name, "module").select_value("Accounts")
      verification(@browser.button(:value, "Next"),"click")

      create_hash
      element_number = @element_number
      @element_number += 1
      @report[:verification]["#{element_number}"][:element] =  "Action: Import Accounts"

      @browser.file_field(:name, "theFile").set(File.join(ENV['HOME'],"Downloads","#{@file_name}"))

      puts_debug_message("Imported file name: #{@file_name}")

      verification(@browser.button(:value, "Next"),"click")
      @browser.select_list(:id,"CrmAccount:ACCOUNTNAME").select("Account Name( Col: 5)")
      verification(@browser.button(:id,"importSubmit"),"click")
      verification(@browser.button(:id,"importSubmit"),"click")

      pass_result(element_number)

      rescue Watir::Exception::UnknownObjectException => we
        fail_result(element_number,we)
      rescue Exception => e
        block_result(element_number,e)
    end
  end

  def test_finalize(report_path)

    tests_results = []

      puts_debug_message("Test results Array: #{tests_results }")

      @report[:verification].each do |test_number, test|
           tests_results << test[:result]
      end

      if tests_results.include?("FAIL")
        @report[:status] = "FAIL"
      elsif tests_results.include?("BLOCK")
        @report[:status] = "BLOCK"
      else
        @report[:status] = "PASS"
      end

    @report[:finish_time] = Time.now

      File.open(report_path, "w+") do |report_file|
        html = html_builder(@report)
        report_file.print html
      end

    @browser.close
  end
end


if (__FILE__ == $0)
  test_title = "Zoho - Watir, Ruby Exercise"
  default_spec_file_path = "./etc/input.json"
  default_report_path = "./reports/report.html"


  opts = Trollop::options do
    banner <<-EOS
#{test_title}
    #{$0} [options]
Where options are:

    EOS
    opt :test_spec, "Relative path to the test specification file", :short => "-i", :default => default_spec_file_path
    opt :output_report_file, "The location of the output report file", :short => "-o", :type => :string, :default => default_report_path
    opt :all, "Start All tests"
    opt :account_verification, "Start 'Account Verification' test"
    opt :blank_account_verification, "Start 'Blank Account Verification' test"
    opt :create_account, "Start 'Create Account' test"
    opt :file_export, "Start 'File Export' test"
    opt :file_import, "Start 'File Import' test"
    opt :verbose, "Print statements about the execution of the test during the run" # By default the verbose value is false
    opt :debug, "Print trace statements during the execution for debugging the test" # By default the debug value is false

  end

  # option validation
  Trollop::die :test_spec, "test specification file (#{opts[:test_spec]}) not found" unless (File.exists?(opts[:test_spec]))

  if opts[:all]
     opts[:create_account]= true
     opts[:account_verification] = true
     opts[:blank_account_verification] = true
     opts[:file_export] = true
     opts[:file_import] = true
  end

  if opts[:account_verification]
     opts[:create_account] = true
  end

  if opts[:file_import]
     opts[:file_export] = true
  end


  test = ZohoCRM.new(opts[:test_spec])
  test.verbose = true if opts[:verbose]
  test.debug = true if opts[:debug]
  test.start_test
  test.login
  test.create_account if opts[:create_account]
  test.account_verification if opts[:account_verification]
  test.blank_account_verification  if opts[:blank_account_verification]
  test.file_export if opts[:file_export]
  test.file_import if opts[:file_import]
  test.test_finalize(opts[:output_report_file])

end