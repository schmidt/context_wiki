module ContextWiki::Views
  module NoKnownUserViews
    def _navigation_links
      @receiver.capture do
        yield
      end.gsub!( @receiver.capture do
        li { a "Users", :href => R(ContextWiki::Controllers::Users) }
      end, "")
    end
  end
  register NoKnownUserViews => ContextR::NoKnownUserLayer
end

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
