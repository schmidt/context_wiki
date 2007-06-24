module ContextWiki::Helpers
  module AdminHelpers
    def footer
      @receiver.capture do
        yield
      end + @receiver.capture do
        text " &middot; "
        text "Admin actions"
      end
    end
  end
  register AdminHelpers => ContextR::AdminLayer
end
