module ContextLogging
  def service(*a)
    t1 = Time.now
    s = super(*a)
    t2 = Time.now
    puts(["\"#{t1.to_formatted_s(:short)}\"",
          "%.2fs" % (t2 - t1),
          env["PATH_INFO"],
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
      @current_user.groups.each do | group |
        layers << group.name.singularize.to_sym
      end
    end
    layers
  end

  def service(*a)
    ContextR::with_layer *compute_current_context do
      @headers['x-contextr'] = ContextR::layer_symbols.join(" ")
      super(*a)
    end
  end
end

