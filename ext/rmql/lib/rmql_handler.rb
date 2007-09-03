module RMQL
  
  # This is the module entrypoint to setup in your controller to handle
  # RMQL queries. This method takes care of creating an evaluator and the parser
  # If the parsing fails, an exception will be thrown, that can be forwarded to the user.
  def handle_rmql_call( query )
    e = RMQLEvaluator.new( nil )
    res = RMQLParser.parse( RMQLLexer.lex( query ) ) 
    if res.is_a? Dhaka::ParseErrorResult
      raise RMQLException( "Error parsing query. Please check the syntax!")
    end
    e.evaluate( res )
  end
  
end