require 'dhaka'
require File.dirname(__FILE__) + '/rmql_grammar'
require File.dirname(__FILE__) + '/rmql_lexer'
require File.dirname(__FILE__) + '/rmql_parser'
require File.dirname(__FILE__) + '/rmql_evaluator'
require File.dirname(__FILE__) + '/rmql_handler'

require File.dirname(__FILE__) + '/rails/active_record'

ActiveRecord::Base.send(:include, Grundprinzip::RMQLActiveRecord)
