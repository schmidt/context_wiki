# This class defines the lexer specification for the subset of XQuery
#
# Possible queries could look like the following example
#
# for $x in User return <user>$x/name</user>
#
class RMQLLexerSpec < Dhaka::LexerSpecification

  keywords = ['for','in', 'return', '{', '}', 'where', 'or', 'and', '(', ')']
  quotes = ['\'']

  keywords.each do |keyword|
    for_symbol( keyword ) do
      create_token( keyword )
    end
  end
    
  quotes.each do |q|
    for_symbol( q ) do
      create_token( "QUOTE")
    end
  end
  
  for_pattern(/[<>=][<>=]?/) do
    create_token( 'COMPARISON')
  end
  
  #for_pattern('\w+\/\w*') do
  #  create_token 'VALUE_SELECTION'
  #end
  
  for_pattern(/\/[a-zA-Z]+[a-zA-Z0-9_]*/) do
    create_token 'FIELD_SELECTION'
  end
  
  for_pattern('\$[a-zA-Z]+[a-zA-Z0-9_]*') do
    create_token 'VARIABLE'
  end
  
  for_pattern("\n") do 
    # noop
  end
  
  for_pattern('<[a-zA-Z]+[a-zA-Z0-9_]*>') do 
    create_token("START_TAG")
  end
  
  for_pattern('<\/\s?[a-zA-Z]+[a-zA-Z0-9_]*>') do 
    create_token("END_TAG")
  end
  
  for_pattern('\(') do 
    create_token('(')
  end
  
  for_pattern('\)') do 
    create_token(')')
  end
  
  for_pattern("[a-zA-Z0-9]+[a-zA-Z0-9_]*") do
      create_token 'WORD_LITERAL'
  end
  
  for_pattern('\s+') do
    # ignore whitespace
  end
  
end

class RMQLGrammar < Dhaka::Grammar
  
  precedences do
     left %w| or |
     left %w| and |
   end
  
  # Startpoint for the Grammar
  for_symbol(Dhaka::START_SYMBOL_NAME) do
    query                     %w| Main |
    query_w_tags          %w| START_TAG Main END_TAG |
  end
  
  for_symbol("atom") do
    atom            %w| WORD_LITERAL |
  end
  
  for_symbol("word_list") do
    word            %w| atom |
    word_w_next     %w| atom word_list |
  end
  
  # This is the initial part of the grammar
  for_symbol('Main') do
    selection                     %w| for VARIABLE in model_definition opt_condition_definition result_exp|    
  end
  
  # Define the optional condition statement
  for_symbol("opt_condition_definition") do
    result_exp_prod         %w| |
    condition_def           %w| where search_condition|
  end
  
  # Result definition
  for_symbol("result_exp") do
    result                        %w| return START_TAG content END_TAG | 
  end
  
  # Search condition definition
  for_symbol("search_condition") do
    search_empty            %w| |
    search_w_or             %w| search_condition or search_condition|
    search_w_and            %w| search_condition and search_condition|
    search_w_parentheses    %w| ( search_condition )|
    search_w_predicate      %w| predicate |
  end
  
  for_symbol("predicate") do
    comparison_predicate_prod  %w| comparison_predicate |
  end
  
  for_symbol("comparison_predicate") do
    comparison              %w| scalar_exp COMPARISON scalar_exp |
  end
  
  for_symbol("scalar_exp") do
    variable_sel_scalar     %w| v_selection |
    word_scalar             %w| atom |
    quoted_word             %w| QUOTE atom QUOTE |
  end
  
  # Two possibilities here either word_literal or model with value selection
  for_symbol("model_definition") do
    model_standard                 %w| atom fields|
    model_variable                  %w| v_selection |
  end
  
  # Content is anything from a word_literal, a variable or another tag
  for_symbol("content") do
    content_words       %w| word_list |
    element             %w| START_TAG content END_TAG |
    sibling             %w| START_TAG content END_TAG content|
    variable_selection  %w| { v_selection }|  
    sub_selection       %w| { Main } |
  end
  
  # v_selection 
  for_symbol( "v_selection" ) do
    variable            %w| VARIABLE |
    variable_w_fields   %w| VARIABLE  fields|
  end
  
  for_symbol( "fields" ) do
    field_noop   %w| |
    field        %w| FIELD_SELECTION |
    field_w_next %w| FIELD_SELECTION fields|
  end
 
end