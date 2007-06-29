module ContextWiki::Helpers
  module RandomHelpers
    def footer
      yield(:receiver).capture do
        yield(:next)
      end + yield(:receiver).capture do
        text " &middot; "
        text "Random actions"
      end
    end
  end
  register RandomHelpers => ContextR::RandomLayer
end
