module ContextLogging
  def service(*a)
    t1 = Time.now
    s = super(*a)
    t2 = Time.now
    puts(["\"#{t1.to_formatted_s(:short)}\"",
          "%.2fs" % (t2 - t1),
          @method.upcase + " " + env["PATH_INFO"],
          @format,
          "(%s)" % ContextR::active_layers.join(", ")].join(" - "))
    s
  end
end

module ContextCamping
  def compute_current_context
    returning(layers = []) do 
      layers << :random if rand(2).zero?

      if @state.current_user
        layers << :known_user
        @current_user = @state.current_user
        registered_groups = @current_user.groups.collect(&:name)
      else
        layers << :unknown_user
        registered_groups = []
      end

      ContextWiki::Models::Group.find(:all).each do | group |
        layers << ((registered_groups.include?(group.name) ? "" : "no_") + 
                    group.name.singularize).to_sym
      end

      layers << "#{@format}_request".to_sym
    end
  end

  def service(*a)
    ContextR::with_layer *compute_current_context do
      @headers['x-contextr'] = ContextR::active_layers.join(" ")
      super(*a)
    end
  end

  def in_reset_context
    ContextR::without_layers *ContextR::active_layers do
      ContextR::with_layers *compute_current_context do
        @headers['x-contextr'] = ContextR::active_layers.join(" ")
        yield
      end
    end
  end

  def self.included(mod)
    ContextR::EventMachine::ContextRListener.class_eval do
      remove_method(:include) if instance_methods(false).include? "include"
    end
  end
end
