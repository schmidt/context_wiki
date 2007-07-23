module UnAuthorized
  VERBS = %w{get post post delete} unless const_defined? :VERBS

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
          yield(:next, *arguments)
        else
          yield(:receiver).instance_eval do
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
          yield(:receiver).instance_eval do
            @status = 401
            render "not_authorized"
          end
        else
          yield(:next, *arguments)
        end
      end
    }, __FILE__, __LINE__
  end
end

module Manipulation
  def manipulate(context, &instructions)
    receiver = context.call(:receiver)
    original_document = receiver.capture do
      context.call(:next)
    end
    receiver << Lilu::Renderer.new(instructions, original_document).execute
  end

  def prepend(context, &instructions)
    receiver = context.call(:receiver)
    original_document = receiver.capture do
      context.call(:next)
    end
    extension = receiver.capture(&instructions)
    receiver << extension + original_document
  end

  def append(context, &instructions)
    receiver = context.call(:receiver)
    original_document = receiver.capture do
      context.call(:next)
    end
    extension = receiver.capture(&instructions)
    receiver << original_document + extension
  end
end

module RESTModels
  def specify_domain_model(options)
    (options[:verbs] || [:get, :put, :post, :delete]).each do | verb |
      self.class_eval %Q{
        def #{verb}(*a)
          if a.last == "#{options[:name]}"
            class << yield(:receiver)
              define_method :model do
                #{options[:model]}
              end
            end
          end
          yield(:next, *a)
        end
      }
    end
  end
end

Lilu::Renderer.class_eval do
  include ContextWiki::Helpers
end
