module Grundprinzip
  module RMQLActiveController
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      # This is the configuration method to define the method, that
      # should be responsible for handling the rmql calls
      def define_rmql_method( name, options = {:variable  => "q"})
        
        define_method(name) {
          e = RMQLEvaluator.new( nil )
          res = RMQLParser.parse( 
            RMQLLexer.lex( 
              params[options[:variable]] ) 
          ) 
          if res.is_a? Dhaka::ParseErrorResult
            raise RMQLException( "Error parsing query. Please check the syntax!")
          end
          r = e.evaluate( res )
          render :text =>  r
        }
      end
    end
    
  end
  
  module RMQLActiveRecord
    
    def self.included(base)
      base.extend ClassMethods
      base.set_default
    end
    
    module ClassMethods

      def excluded_from_rmql
        read_inheritable_attribute( "rmql_excluded")
      end

      def rmql_methods_list
        read_inheritable_attribute( "rmql_methods" )
      end

      # This is a Class Method for a ActiveRecord::Base class to
      # manually exclude a model from any RMQL call. Trying to invoke
      # any actions on this model results in a RMQLSecurityException
      # 
      # If you want to protect your model from RMQL calls structure your
      # class code like the following
      #
      #   class SampelModel < ActiveRecord::Base
      #     exclude_from_rmql
      #   end
      def exclude_from_rmql
        write_inheritable_attribute( "rmql_excluded", true )
      end

      # This method is a more fine grained variant of exclude_from_rmql
      # it allows to define a fine level of access to the model. It allows
      # to provide either :exclude or :only array as parameters. 
      #
      # * :exclude expects a list of symbols that define methods, that are not
      #   allowed to call
      # * :only defines a list of methods as symbols, that are allowed to called
      #   any other method is forbidden
      #
      # Any failure of this constraint validation results in a RMQLSecurityException
      #
      # A combination of :excluded or :obly is not allowed
      def rmql_methods( options = {})
        if options.has_key?( :excluded ) and options.has_key?( :only )
          raise ArgumentError("A combination of :excluded and :only is forbidden")
        end
        write_inheritable_hash( "rmql_methods", options)
      end
      
      def set_default
        write_inheritable_attribute( "rmql_excluded", false )
        write_inheritable_hash( "rmql_methods", {})
      end
      
    end
  end
end
