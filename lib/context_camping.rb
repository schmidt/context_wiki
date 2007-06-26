module ContextLogging
  def service(*a)
    t1 = Time.now
    s = super(*a)
    t2 = Time.now
    puts(["\"#{t1.to_formatted_s(:short)}\"",
          "%.2fs" % (t2 - t1),
          @method.upcase + " " + env["PATH_INFO"],
          "(%s)" % ContextR::layer_symbols.join(", ")].join(" - "))
    s
  end
end

module ContextCamping
  include ContextLogging
  def compute_current_context
    layers = []
    layers << :random if rand(0).round.zero?
    if @state.current_user
      layers << :known_user
      @current_user = @state.current_user
      registered_groups = @current_user.groups.collect(&:name)
    else
      layers << :no_known_user
      registered_groups = []
    end
    ContextWiki::Models::Group.find(:all).each do | group |
      layers << ((registered_groups.include?(group.name) ? "" : "no_") + 
                  group.name.singularize).to_sym
    end
    layers
  end

  def service(*a)
    ContextR::with_layer *compute_current_context do
      @headers['x-contextr'] = ContextR::layer_symbols.join(" ")
      super(*a)
    end
  end

  def in_reset_context
    y ContextR::layer_symbols
    ContextR::without_layers *ContextR::layer_symbols do
      ContextR::with_layers *compute_current_context do
        y ContextR::layer_symbols
        @headers['x-contextr'] = ContextR::layer_symbols.join(" ")
        yield
      end
    end
  end
end
