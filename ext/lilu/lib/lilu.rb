require 'rubygems'
require 'hpricot'
require 'active_support'

class Hpricot::Elem
  attr_accessor :cache_search
  alias :_search :search
  def search(expr,&block)
    if @_inner_html
      self.inner_html= @_inner_html 
      @_inner_html = nil
    end
    if cache_search
      @_search ||= {}
      @_search[expr] || @_search[expr] = _search(expr,&block)
    else
      _search(expr,&block)
    end
  end

  def _inner_html=(html)
    @_inner_html = html
  end

  alias :_output :output
  def output(out, opts={})
    if @_inner_html
      if empty? and ElementContent[@stag.name] == :EMPTY
        @stag.output(out, opts.merge(:style => :empty))
      else
        @stag.output(out, opts)
        out << @_inner_html
        if @etag
          @etag.output(out, opts)
        elsif !opts[:preserve]
          ETag.new(@stag.name).output(out,opts)
        end
      end
    else
      _output(out,opts)
    end
  end

end
module Lilu

  module Version ; MAJOR, MINOR, TINY = 0, 1, 2 ; end

  class Action
    attr_accessor :element
    attr_reader :renderer
    def initialize(element,renderer)
      @element, @renderer = element, renderer
      renderer.action = self
    end
  end


  class Populate < Action
    def method_missing(sym,*args)
      send :for, sym, *args
    end
    
    def for(method,data,&block)
      return element.collect {|e| self.element = e ; renderer.instance_eval { action.for(method,data,&block) } } if element.is_a?(Hpricot::Elements)

      element.cache_search = true
      update_action = Update.new(element,renderer)
      parent = element.parent
      element_html = element.to_html
      data.send(method) do |*objects| 
        update_action.element = element
        update_action.with(block.call(*objects))

        parent.insert_before(Hpricot.make(element.to_html),element) 
        element = Hpricot.make(element_html)
      end
      renderer.action = self 

      Hpricot::Elements[element].remove
    end
  end

  class Remove < Action
    def initialize(*args)
      super(*args)
      return element.remove if element.is_a?(Hpricot::Elements)
      Hpricot::Elements[element].remove
    end
  end

  class Replace < Action
    def with(new_element=nil,&block)
      return element.collect {|e| self.element = e ; renderer.instance_eval { action.with(new_element) } } if element.is_a?(Hpricot::Elements)
      case new_element
      when String
        element.swap new_element
      when Hpricot::Elem
        Hpricot::Elements[new_element].remove
        element.parent.insert_after(new_element,element)
        Hpricot::Elements[element].remove
      when Proc
        with(new_element.call.to_s)
      when nil
        with(block.call) if block_given?
      else
        element.swap new_element.to_s
      end
    end
  end

  class Update < Action

    def with(arg=nil,&block)
      return element.collect {|e| self.element = e ; renderer.instance_eval { action.with(arg,&block) } } if element.is_a?(Hpricot::Elements)
      case arg
      when Hash
        arg.each_pair do |path,value|
          value = value.call if value.is_a?(Proc)
          case path
          when String
            elem = element.at(path)
            raise ElementNotFound.new(elem) unless elem

            saved_element = element
            self.element = elem
            res = with(value,&block)
            self.element = saved_element
            res
          when Replacing
            Replace.new(path.element,renderer).with value.to_s
          when renderer
            element._inner_html = value.to_s
          else
            element[path] = value.to_s
          end
        end
      when Proc
        with arg.call
      when nil
        with renderer.instance_eval(&block) if block_given?
      else  
        element._inner_html = arg.to_s
      end
    end


  end

  class Use < Action
    def initialize(*args)
      super(*args)
      raise ArgumentError.new("Use action can not accept :all parameter") if element.is_a?(Hpricot::Elements)
      renderer.doc = element
    end
  end

  # Experimental stuff
  class Replacing
    attr_reader :element
    def initialize(renderer,element)
      @renderer = renderer
      case element
      when String
        @element = renderer.element_at(element)
      when Hpricot::Elem, Hpricot::Elements
        @element = element
      end
    end
  end
  #

  class ElementNotFound < Exception
    def initialize(element)
      super("Element #{element} was not found")
    end
  end

  class Renderer
    attr_accessor :action, :doc
    attr_reader :instructions, :html_source

    def element
      action.element
    end

    def initialize(instructions,html_source,local_assignments={})
      @instructions = instructions
      @html_source = html_source
      @doc = Hpricot(@html_source)
      @view = local_assignments["___view"] if local_assignments.is_a?(Hash)
      inject_local_assignments(local_assignments)
    end


    def execute
      instance_eval( &@instructions )
      @doc.to_html
    end


    def apply
      eval(@instructions) do |*name|
        name = name.first 
        name = 'layout' if name.nil?
        instance_variable_get("@content_for_#{name}")
      end
      @doc.to_html
    end

    %w[update populate remove use replace].each {|method_name| module_eval <<-EOL
      def #{method_name}(*path)
        elem = find_elements(*path)
        path.pop if path.first == :all
        raise ElementNotFound.new(path) unless elem
        Lilu::#{method_name.camelize}.new(elem,self)
      end
      EOL
    }


    def mapping(opts={})
      opts
    end

    # Helper for partials
    def partial(name,opts={})
      render({:partial => name}.merge(opts))
    end

    # Helper for lambda
    alias_method :L, :lambda

    def element_at(path)
      doc.at(path)
    end

    def method_missing(sym,*args)
      return @view.send(sym,*args) if @view and @view.respond_to?(sym)
      return instance_variable_get("@#{sym}") if args.empty? and instance_variables.member? "@#{sym}"
      return @controller.send(sym, *args) if @controller and @controller.respond_to?(sym)
      super #raise NoMethodError.new(sym.to_s)
    end

    # Helper for replacing
    def replacing(element)
      Replacing.new(self,element)
    end

    protected

    def find_elements(*path)
      path_first, path_second = path[0], path[1]
      case path_first
      when Hpricot::Elem, Hpricot::Elements
        path_first
      when :all
        raise InvalidArgument.new("if :all is specified, second argument with path should be specified as well") unless path_second
        doc.search(path_second)
      else
        doc.at(path_first)
      end
    end

    def inject_local_assignments(local_assignments)
      case local_assignments
      when Hash
        local_assignments.each_pair {|ivar,val| instance_variable_set(ivar.to_s.starts_with?('@') ? ivar : "@#{ivar}", val) }
      when Binding
        eval("instance_variables",local_assignments).each {|ivar| instance_variable_set(ivar, eval("instance_variable_get('#{ivar}')",local_assignments)) }
      else
        local_assignments.instance_variables.each {|ivar| instance_variable_set(ivar.to_s.starts_with?('@') ? ivar : "@#{ivar}", local_assignments.instance_variable_get(ivar)) }
      end
    end

  end

end
