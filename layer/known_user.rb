module ContextWiki::Helpers
  module KnownUserHelpers
    def footer
      @receiver.capture do
        yield
      end + @receiver.capture do
        text " &middot; "
        text "Actions for #{state.current_user}"
      end
    end
  end
  register KnownUserHelpers => ContextR::KnownUserLayer
end
