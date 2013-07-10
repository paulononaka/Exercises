#!/bin/bash

#Commands to execute zoho_crm.rb
#
#Options:
#--test-spec or -i - Relative path to the test specification file, by default ./etc/input.json
#--output-report-file or -o - The location of the output report file, by default ./reports/report.html 
#--all - Start All tests
#--account-verification - Start 'Account Verification' test
#--blank-account-verification - Start 'Blank Account Verification' test
#--create-account - Start 'Create Account' test
#--file-export - Start 'File Export' test
#--file-import - Start 'File Import' test
#--verbose - Print statements about the execution of the test during the run
#--debug - Print trace statements during the execution for debugging the test

#To install all necessary gems, uncomment bundle install

# bundle install
  ruby ./lib/zoho_crm.rb --all
# ruby ./lib/zoho_crm.rb --all
# ruby ./lib/zoho_crm.rb --create-account
# ruby ./lib/zoho_crm.rb --account-verification
# ruby ./lib/zoho_crm.rb --blank-account-verification
# ruby ./lib/zoho_crm.rb --file-export
# ruby ./lib/zoho_crm.rb --file-import