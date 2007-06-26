module UnAuthorized
  VERBS = %w{get post post delete}

  def restrict_access(verb, option = nil)
    VERBS.each { |v| restrict_access(v, option) } if verb == :all
    option = { :disallow => "/.*/" } if option == :disallow

    key, value = option.to_a.first
    case key
    when :allow
      allow(verb, value)
    when :disallow
      disallow(verb, value)
    else
      ArgumentError.new "Wrong option key given: :#{key}. 
                         Use only :allow or :disallow.".squeeze(" ")
    end
  end

  def allow(verb, allowed_methods)
    self.class_eval %Q{
      def #{verb}(*arguments)
        path = arguments.join "/"
        path = "" if path.empty?
        if path =~ #{allowed_methods}
          yield(*arguments)
        else
          @receiver.instance_eval do
            @status = 401
            render "not_authorized"
          end
        end
      end
    }, __FILE__, __LINE__
  end

  def disallow(verb, restricted_methods)
    self.class_eval %Q{
      def #{verb}(*arguments)
        path = arguments.join "/"
        path = "" if path.empty?
        if path =~ #{restricted_methods}
          @receiver.instance_eval do
            @status = 401
            render "not_authorized"
          end
        else
          yield(*arguments)
        end
      end
    }, __FILE__, __LINE__
  end
end
