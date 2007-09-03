require 'test/unit'
require File.dirname(__FILE__) + "/test_helper"
require File.dirname(__FILE__) + "/mocks"


class RMQLTest < Test::Unit::TestCase
  
  def setup
    @q1 = "for $user in user return <user>{$user/name}</user>"
    @q2 = "for $user in user return <user><name>{$user/name}</name><first_name>{$user/first_name}</first_name></user>"
    @q3 = "for $user in user where $user/name = 'Martin' return <user>{$user/name}</user>"
    @q4 = "for $user in user where $user/first_name = 'Martin' and $user/last_name = 'Grund' return <user>{$user/first_name}</user>"
    @q5 = "for $user in user where $user/first_name = 'Martin' or $user/last_name = 'Grund' return <user>{$user/first_name}</user>"
    @q6 = "for $user in user where $user/first_name = 'Martin' and ($user/last_name = 'Grund' or  'Name' = 'hase')return <user>{$user/first_name}</user>"
    
    @q7 = "for $x in User/fotos return <foto>{$x/title}</foto>"
    @q8 = "<users>for $user in User return <user>{$user/name}</user></users>"
    @q9 = "for $user in User return <user><name>{$user/name}</name><fotos>{for $foto in $user/fotos return <foto><title>{ $foto/title }</title></foto>}</fotos></user>"
    
    @q10 = "<users>\nfor $user in User return <user>{$user/name}</user>\n</users>"
    
    @f1 = "for $user in user return <user>{$user/name}"
    @f2 = "for $user in user return <user>{$user/name}<a></user>"
    @f3 = "for $user in user return <user>{$user/name}<a></user></a>"
    @f4 = "for $user in other_user return <user>{$user/name}</user>"
    @f5 = "for $x in User return <foto>{$x/save}</foto>"
    @f6 = "for $x in User return <foto>{$x/delete}</foto>"
    @f7 = "for $x in User return <foto>{$x/destroy}</foto>"
    @f8 = "for $x in User return <foto>{$x/create}</foto>"
  end
  
  def help_evaluate( query )
    e = RMQLEvaluator.new( STDOUT )
    res = RMQLParser.parse( RMQLLexer.lex( query ) ) 
    if res.is_a? Dhaka::ParseErrorResult
      p res
    end
    e.evaluate( res )
  end
  
  def test_subselect
    result = help_evaluate( @q9 )
    assert("<user><name>Lustig</name><fotos><foto><title>Foto 1</title></foto><foto><title>Foto 1</title></foto></fotos></user>",
      result)
  end
  
  def test_parser
    lexed = RMQLLexer.lex(@q1)
    parsed = RMQLParser.parse(lexed)
    assert(Dhaka::ParseSuccessResult, parsed)
    
    lexed = RMQLLexer.lex(@f1)
    parsed = RMQLParser.parse(lexed)
    assert(Dhaka::ParseErrorResult, parsed)
    
    lexed = RMQLLexer.lex(@f2)
    parsed = RMQLParser.parse(lexed)
    assert(Dhaka::ParseErrorResult, parsed)
    
    lexed = RMQLLexer.lex(@f3)
    parsed = RMQLParser.parse(lexed)
    assert(Dhaka::ParseErrorResult, parsed)    
  end
  
  def test_parse_result
    lexed = RMQLLexer.lex(@q1)
    parsed = RMQLParser.parse(lexed)
    
    assert(Dhaka::ParseSuccessResult, parsed)
    
    evaluator = RMQLEvaluator.new( nil )
    assert( "<user>Lustig</user>" , evaluator.evaluate( parsed ))    
  end
  
  def test_parse_multiple_variables
    result = help_evaluate( @q2)
    assert( "<user><name>Lustig</grund><first_name>Peter</first_name></user>", result)
  end
  
  
  def test_main_with_tags
    result = help_evaluate( @q8)
    assert( "<users><user><name>Lustig</grund><first_name>Peter</first_name></user></users>", result)
  end
  
  def test_main_with_newlines
    result = help_evaluate( @q10)
    assert( "<users><user><name>Lustig</grund><first_name>Peter</first_name></user></users>", result)
  end
  
  def test_with_condtion
    result = help_evaluate( @q3 )
    assert( "<user>Grund</user>", result)
  end
  
  def test_with_and_condition
    result = help_evaluate( @q4 )
    assert( "<user>and</user>", result)
  end
  
  def test_with_and_condition
    result = help_evaluate( @q5 )
    assert( "<user>or</user>", result)
  end
  
  def test_with_and_or_and_parenth_condition
    result = help_evaluate( @q6 )
    assert( "<user>complex</user>", result)
  end

  def test_with_and_or_and_parenth_condition
    result = help_evaluate( @q7 )
    assert( "<foto>Foto 1</foto>", result)
  end  
  
  def test_only_secured
    assert_nothing_raised do
      help_evaluate( @q7 )
    end
    assert_raise RMQLSecurityException do
     help_evaluate( @f4 )
    end
  end
  
  def test_secured_methods
    assert_raise RMQLSecurityException do
     help_evaluate( @f5 )
    end
    assert_raise RMQLSecurityException do
     help_evaluate( @f6 )
    end
    assert_raise RMQLSecurityException do
     help_evaluate( @f7 )
    end
    assert_raise RMQLSecurityException do
     help_evaluate( @f8 )
    end
  end
  
  def test_exlude_model
    assert_raise RMQLSecurityException do
      help_evaluate( "for $x in Excluded return <a>{$x}</a>" )
    end
  end
  
  def test_exlude_methods
    assert_nothing_raised RMQLSecurityException do
     help_evaluate( "for $x in only_some_methods return <a>{$x/only}</a>" )
    end
    assert_raise RMQLSecurityException do
     help_evaluate( "for $x in only_some_methods return <a>{$x/no}</a>" )
    end
    
    assert_nothing_raised RMQLSecurityException do
     help_evaluate( "for $x in except_some_methods return <a>{$x/yes}</a>" )
    end
    
    assert_raise RMQLSecurityException do
     help_evaluate( "for $x in except_some_methods return <a>{$x/except}</a>" )
    end
  end
  
  
end
