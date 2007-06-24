module ContextWiki::Helpers
  module RandomHelpers
    def footer
      @receiver.capture do
        yield
      end + @receiver.capture do
        text " &middot; "
        text "Random actions"
      end
    end
  end
  register RandomHelpers => ContextR::RandomLayer
end
