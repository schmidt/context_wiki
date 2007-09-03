# Include hook code here
require 'dhaka'
require 'rmql_grammar'
require 'rmql_lexer'
require 'rmql_parser'
require 'rmql_evaluator'
require 'rmql_handler'

require 'rails/active_record'
#require 'rails/action_controller'

ActiveRecord::Base.send(:include, Grundprinzip::RMQLActiveRecord)
ActionController::Base.send(:include, Grundprinzip::RMQLActiveController)