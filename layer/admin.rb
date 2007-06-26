module ContextWiki::Views
  module NoAdminViews
    def _navigation_links
      @receiver.capture do
        yield
      end.gsub( @receiver.capture do
        li { a "Groups", :href => R(ContextWiki::Controllers::Groups) }
      end, "")
    end
    def _authenticated_box
      ""
    end
  end
  register NoAdminViews => ContextR::NoAdminLayer
end

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
  register AdminHelpers   => ContextR::AdminLayer
end
