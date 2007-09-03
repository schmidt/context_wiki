require 'rubygems'
require 'dhaka'




##########################################################
require 'rmql_grammar'

l = Logger.new( nil )

lexer = Dhaka::Lexer.new(RMQLLexerSpec)
parser = Dhaka::Parser.new(RMQLGrammar, l)

File.open('rmql_lexer.rb', 'w') {|file| file << lexer.compile_to_ruby_source_as(:RMQLLexer)}
File.open('rmql_parser.rb', 'w') {|file| file << parser.compile_to_ruby_source_as(:RMQLParser)}

#puts RMQLGrammar.to_bnf

#q = "for $x in User where $x = 'b' and $x = 'Martin' or $x/name = 'Peter' return <user><name>{$x/first}</name><first>{$x/first_name}</first></user>"
#q = "for $user in user where $user/first_name = 'Martin' and $user/last_name = 'Grund' return <user>{$user/name}</user>"
q = "for $x in User_name/fotos return <foto>{$x/title}</foto>"
#q = "for $user in user return <user><name>{$user/name}</name><first_name>{$user/first_name}</first_name></user>"
result = lexer.lex(q)
#result = lexer.lex("for $x in User return <user><name>{$x/nice}</name></user>")


#puts "*" * 40
presult = parser.parse(result)
p presult.class.name



# File.open('parser.dot', 'w') do |file| 
#   file << parser.to_dot
# end
# 
# File.open('parse_tree.dot', 'w') do |file| 
#   file << presult.to_dot
# end

