ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + '/../../../../config/environment')

plugin_path = RAILS_ROOT + "/vendor/plugins/rmql/"

require 'dhaka'
require plugin_path + "lib/rails/active_record"

ActiveRecord::Base.send(:include, Grundprinzip::RMQLActiveRecord)

# require plugin_path + 'rmql_grammar'
# require plugin_path + 'rmql_lexer'
# require plugin_path + 'rmql_parser'
# require plugin_path + 'rmql_evaluator'

