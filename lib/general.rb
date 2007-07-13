class NilClass
  def try
    @blackhole ||= Object.new.instance_eval do
      class << self
        for m in public_instance_methods
          undef_method(m.to_sym) unless m =~ /^(__.*__|inspect)$/
        end
      end
      def method_missing(*args); nil; end
      self
    end
    @blackhole
  end
end

class Object
  def try 
    self
  end
end 

class Class
  def nsf_name
    name.scan(/([^:]+)$/).first.first
  end
end


# Patch for Rails #8305 that I submitted on 2007-05-09
# We'll need to keep an eye out upon next Rails Gem upgrade whether or not this 
# fix has been applied to remove this or not.
module NSFToXmlMixin
  def to_xml(options = {}, &block)
    options[:root] ||= self.class.nsf_name.tableize.singularize
    super(options, &block)
  end
end
class ActiveRecord::Base
  include NSFToXmlMixin
end

module ContainerPatchMixin
  def self.included(base)
    base.class_eval %{ alias :old_to_xml :to_xml }
    base.send(:include, InstanceMethods)
  end

  module InstanceMethods
    def to_xml(options = {})
      contained_class = self.first.class.nsf_name
      options[:root] ||= contained_class.tableize
      options[:children] ||= 
            contained_class.tableize.singularize
      super(options)
    end
  end
end

class Array
  include ContainerPatchMixin
end
