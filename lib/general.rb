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
