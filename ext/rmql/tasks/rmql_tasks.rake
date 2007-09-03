# desc "Explaining what the task does"
# task :rmql do
#   # Task goes here
# end

desc "Generate new parser and lexer if the grammar or lexer specification changed"
task :rmql_generate do
  require 'rubygems'
  require 'dhaka'
  require File.dirname(__FILE__) + '/../lib/rmql_grammar'

  l = Logger.new( nil )
  lexer = Dhaka::Lexer.new(RMQLLexerSpec)
  parser = Dhaka::Parser.new(RMQLGrammar, l)
  File.open(File.dirname(__FILE__) + '/../lib/rmql_lexer.rb', 'w') {|file| file << lexer.compile_to_ruby_source_as(:RMQLLexer)}
  File.open(File.dirname(__FILE__) + '/../lib/rmql_parser.rb', 'w') {|file| file << parser.compile_to_ruby_source_as(:RMQLParser)}
end