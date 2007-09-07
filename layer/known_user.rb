module ContextWiki::Views
  module NoKnownUserViews
    include Manipulation
    def _navigation_links(&context)
      manipulate(context) do
        update("li.profile a").with(
                          text => "Sign Up",
                          :href => R(ContextWiki::Controllers::Users, :new))
        update("li.session a").with(
                          text => "Log in",
                          :href => R(ContextWiki::Controllers::Sessions, :new))
        remove("li.users")
      end
    end
  end

  module KnownUserViews
    include Manipulation
    def _navigation_links(&context)
      manipulate(context) do
        update("li.session a").with text => "Log Out"
      end
    end
  end
  include NoKnownUserViews => :no_known_user,
          KnownUserViews   => :known_user
end

module ContextWiki::Helpers
  module KnownUserHelpers
    include Manipulation
    def footer(&context)
      append(context) do
        text " &middot; "
        text "Actions for #{state.current_user}"
      end
    end
  end
  include KnownUserHelpers => :known_user
end
