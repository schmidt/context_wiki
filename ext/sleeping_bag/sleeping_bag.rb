module SleepingBag
  HTTP_METHODS = [:get, :post, :put, :delete, :head]
  
  def self.included(controller)
    controller.send(:extend, ClassMethods)
    controller.send(:include, InstanceMethods)
  end
  
  module ClassMethods
    @@standard_actions = [:index, :create, :show, :destroy, :update]
    def standard_actions; @@standard_actions end
    
    @@methods = Hash.new([:get])
    @@methods.update({:create => [:post], :destroy => [:delete], :update => [:put]})
    def methods; @@methods end
    
    def collection_actions
      public_instance_methods.map{|m| m.to_sym}.select{|m| instance_method(m).arity == 0}
    end
    
    def member_actions
      public_instance_methods.map{|m| m.to_sym}.select{|m| instance_method(m).arity == 1}
    end
    
    def standard_collection_actions
      collection_actions.select{|a| standard_actions.include?(a)}
    end
    
    def custom_collection_actions
      collection_actions.select{|a| !standard_actions.include?(a)}
    end
    
    def standard_member_actions
      member_actions.select{|a| standard_actions.include?(a)}
    end
    
    def custom_member_actions
      member_actions.select{|a| !standard_actions.include?(a)}
    end
  end
  
  module InstanceMethods
    HTTP_METHODS.each do |method|
      module_eval "def #{method}(*args); dispatch(:#{method}, args) end"
    end
    
  protected
    def not_found
      r(404, Camping::Mab.new{h1("Not found")})
    end
    
    def recognize(method, args)
      case args.size
      when 0
        if action = self.class.standard_collection_actions.detect{|a| self.class.methods[a].include?(method)}
          action
        end
      when 1
        if action = self.class.custom_collection_actions.detect{|a| a == args.first.to_sym && self.class.methods[a].include?(method)}
          action
        elsif action = self.class.standard_member_actions.detect{|a| self.class.methods[a].include?(method)}
          [action, args.first]
        end
      when 2
        if action = self.class.custom_member_actions.detect{|a| a == args.last.to_sym && self.class.methods[a].include?(method)}
          [action, args.first]
        end
      end
    end
    
    def dispatch(method, args)
      action, id = recognize(method, args)
      
      if action
        self.send(action, *[id].compact)
      else
        not_found
      end
    end
  end
end