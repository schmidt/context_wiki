# We need to add some string routines here
# if not String.methods.include?("classify")
#   class String    
#     def classify
#       self[0..0].upcase + self[1..-1]
#     end
#     
#     def constantize
#       Object.module_eval("::#{self}", __FILE__, __LINE__)
#     end
#     
#   end
# end

class RMQLException < Exception
end

class RMQLSecurityException < Exception
end


# This is the evaluation class for a given inputstring
#
# Since we can call almost all methods on a specifice Ruby Object that is
# defined we need to make sure, that some methods cannot be called and we
# are sure, that the actual model is a subclass of ActiveRecord::Base
class RMQLEvaluator < Dhaka::Evaluator
  
  # Checker to accept only calls in Rails mode
  cattr_reader :rails_mode
  @@rails_mode = true
  
  # Define some fields that are forbidden by default
  cattr_reader :forbidden_fields
  @@forbidden_fields = [:save, :destroy, :create, :delete]
  
  self.grammar = RMQLGrammar
  
  attr_accessor :logger
  
  def initialize( output = STDOUT)
    # global stack fram storage
    @stack = []
    @logger = Logger.new( output )
  end
  
  # Lookup any variable from the current stack frame
  # 
  # If the variable was found return it or otherwise raise
  # a variable not declared exception
  def lookup_variable( name )
    logger.debug( "Variable: #{name}")
    # Iterate over the whole stack to lookup the
    # variable
    @stack.each do |frame|
      if frame[:element][:name] == name
        return frame[:element][:value]
      elsif frame.keys.include?( name )
        return frame[name.to_sym]
      end
    end
    
    raise RMQLException.new("Variable #{name} undeclared!")
  end
  
  # Invoke a list of methods on a current 
  # variable from the stack
  def checked_method_invoke( map )
    return "" if not map.is_a? Hash
    
    check_fields_for_forbidden_methods( map[:model], map[:fields])
    
    obj = lookup_variable( map[:name] )
    
    result = obj
    map[:fields].each do |field|
      result = result.send( field.to_sym )
    end
    return result.to_s
  end
  
  # This method will check if the current execution stack is allowed for the
  # model.This includes checks on the current static forbidden list as well
  # as checks on the dynamic :exclude or :only methods for the current model
  def check_fields_for_forbidden_methods( model_class, fields)
    
    fields.each do |f|
      
      # This is the static check
      if forbidden_fields.include?( f.to_sym )
        raise RMQLSecurityException.
          new("Call to method #{f} on #{model_class} is not allowed in this context.")
      end
      
      # Now follows the dynamic check
      if model_class.rmql_methods_list.has_key?( :exclude ) and 
          model_class.rmql_methods_list[:exclude].include?( f.to_sym )
        raise RMQLSecurityException.
          new("Call to method #{f} on #{model_class} is not allowed in this context.")
      elsif model_class.rmql_methods_list.has_key?( :only ) and 
          not model_class.rmql_methods_list[:only].include?( f.to_sym )
        raise RMQLSecurityException.
          new("Call to method #{f} on #{model_class} is not allowed in this context.")
      end
            
    end
  end
  
  # Invoke a checked call on a model method from the current 
  # stack frame. A model can be dynamically exclueded from the call list using
  # the exclude_from_rmql_list defined for each ActiveRecord::Base model.
  def checked_model_call( fields = [] )
    frame = @stack[-1]

    if rails_mode
      
      if not frame[:model] < ActiveRecord::Base
        raise RMQLSecurityException.
          new("Model ( #{frame[:model]} ) defined in this query is not a subclass of ActiveRecord::Base")
      end
      
      # Check if the current model is allowed to be called
      if frame[:model].excluded_from_rmql == true
        raise RMQLSecurityException.
          new("Model ( #{frame[:model]} ) is forbidden to be called")
      end
    end
    
    if fields.empty?
      if frame[:conditions].blank?
        frame[:result] = frame[:model].find( :all )
      else
        frame[:result] = frame[:model].find( :all,
          :conditions => frame[:conditions])
      end
    else
      check_fields_for_forbidden_methods( frame[:model], fields)
      if frame[:conditions].blank?
        frame[:result] = frame[:model].send( fields.first )
      else
        frame[:result] = frame[:model].send( fields.first,
          :conditions => frame[:conditions])
      end
    end
    
  end
  
  # This method is used to do a checked model call on a variable. Since we 
  # have a result object already in the variable we need to check, after we called
  # the method and iterate over the result to check if everything is fine
  def checked_model_call_from_variable( map )
    return "" if not map.is_a? Hash
    obj = lookup_variable( map[:name] )
    result = obj
    map[:fields].each do |field|
      result = result.send( field.to_sym )
    end
    
    if not result.kind_of? Array
      result = [result]
    end
    
    # Only in Rails mode execute the model class checks
    if rails_mode
      result.each do |res|
        check_fields_for_forbidden_methods( res.class , map[:fields])
      end
    end
    
    # FIXME we assume, that all elements of the returning array have only
    # one class, damn static typing
    @stack[-1][:model] = result.first.class
    
    @stack[-1][:result] = result
  end
  
  ############################################################################
  define_evaluation_rules do

    for_query_w_tags do
      result = ""
      result << child_nodes[0].token.value
      result << evaluate( child_nodes[1] )
      result << child_nodes[2].token.value
      result
    end

    # This is the starting point for each selection statement
    for_selection do

      stack_frame = {}
      variable_leaf = child_nodes[1]
      stack_frame[:element] = {:name => variable_leaf.token.value, 
        :value => nil}
      @stack << stack_frame
      
      # Build the condition
      conditions = evaluate( child_nodes[4])
      stack_frame[:conditions] = conditions
      
      # Evaluate the model classes
      model_nodes = evaluate( child_nodes[3] )
      
      # Build the result
      result = evaluate( child_nodes[5] )
      result
    end
    
    # This production is called if we add a sub selection statement
    # in this case we only evaluate the second node, since here the main production
    # is defined.
    for_sub_selection do
      evaluate( child_nodes[1] )
    end
    
    for_result_exp_prod do
      # NOOP here, since there is no condition
    end
    
    for_field_noop do
      # NOOP for empty fields
      []
    end
    
    for_condition_def do
      if not child_nodes.empty?
        evaluate( child_nodes[1])
      end
      []
    end
    
    # Combine two comparisons with and
    for_search_w_and do 
      left = evaluate( child_nodes[0] )
      right = evaluate( child_nodes[2] )
      
      [left.first + " and " + right.first]
    end
    
    # with or...
    for_search_w_or do 
      left = evaluate( child_nodes[0] )
      right = evaluate( child_nodes[2] )
      
      [left.first + " or " + right.first]
    end
    
    # and with "(" and ")"
    for_search_w_parentheses do
      ["( " + evaluate( child_nodes[1] ).first + " )"]
    end
    
    # This is the evaluation method for a single comparison
    # the middle node is the operator and the left and right node are the contents
    for_comparison do
      logger.debug "comparison"
      left = evaluate( child_nodes[0])
      operator = child_nodes[1].token.value
      right = evaluate( child_nodes[2] )
      
      where = ""
      #TODO methodnames vs. columnnames
      if left.is_a? Hash
        if left[:fields].empty?
          raise "Cannot compare Variable. Please check your definition"
        end
        where << left[:fields].first
      else
        where << "'" << left << "'"
      end
      
      where << " " << operator << " "
      
      #TODO methodnames vs. columnnames
      if right.is_a? Hash
        if right[:fields].empty?
          raise "Cannot compare Variable. Please check your definition"
        end
        where << right[:fields].first
      else
        where << "'" << right << "'"
      end
      
      [where]
    end
    
    # define the result structure
    # The result must be a valid xml document, so we have at least
    # one start_tag and one end_tag
    for_result do
      logger.debug "result"
      
      frame = @stack[-1]
      document = ""
      # We always assume that the result is an array
      frame[:result].each do |element|
        # Fist save the element value to the stack
        frame[:element][:value] = element
        
        #Now go done the stack
        document << child_nodes[1].token.value
        document << evaluate( child_nodes[2] )
        document << child_nodes[3].token.value
                
      end
      document
    end
  
    # This is the method that helps us finding the model
    # this node has only one child wich is a word literal
    for_model_standard do
      logger.debug "model_standard"
      
      # Get the model name from the child node
      model_name = evaluate(child_nodes[0]).classify
      frame = @stack[-1]
      
      fields = evaluate(child_nodes[1])
      frame[:model] = self.class.module_eval(model_name.classify)
      
      checked_model_call(fields)
    end
    
    # This method is called if we have a selection based on a variable that was defined
    # in the above stack_frame
    for_model_variable do
      logger.debug "model from variable"
      var_value = evaluate( child_nodes[0] )
      checked_model_call_from_variable( var_value )
    end
  
    # Evaluate a word means returning the value of the token
    for_atom do
      child_nodes[0].token.value
    end
    
    # Evalutate a quoted word
    for_quoted_word do
      evaluate( child_nodes[1] ) 
    end
  
    # This is the actual variable selection here, we look if we can find 
    # the defined variable in the current stack_frame or it is the current
    # element
    for_variable_selection do
      logger.debug("variable_selection")
      map = evaluate( child_nodes[1] )
      p map
      checked_method_invoke( map )
    end
    
    for_variable do
      logger.debug("variable")
      {:name => child_nodes[0].token.value, :fields => [],
        :model => @stack[-1][:model]}
    end
    
    # Variable definition with fields accessors
    for_variable_w_fields do
      logger.debug("variable_w_field")
      variable_name = child_nodes[0].token.value
      
      fields = []
      fields += evaluate( child_nodes[1] )

      # Do the lookup for the variable
      {:name => variable_name, :fields => fields,
        :model => @stack[-1][:model]}      
    end
    
    # Select a single field
    for_field do
      [child_nodes[0].token.value.gsub("/","")]
    end
  
    # Select the next field and iterate to the next field
    for_field_w_next do 
      [child_nodes[0].token.value.gsub("/","")] + 
        evaluate( child_nodes[1])
    end
  
    for_element do
      logger.debug("element")
      frame = @stack[-1]
      r = child_nodes[0].token.value + evaluate( child_nodes[1] ) + child_nodes[2].token.value
      r
    end
      
    for_sibling do
      frame = @stack[-1]
      result = child_nodes[0].token.value +
        evaluate( child_nodes[1] ) + 
        child_nodes[2].token.value + 
        evaluate( child_nodes[3] )
      result
    end    
    
  end
end

