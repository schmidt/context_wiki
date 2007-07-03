module ContextWiki::Views
  module NoKnownUserViews
    include Manipulation
    def _navigation_links(&context)
      manipulate(context) do
        update("li.profile a").with(
                          self => "Sign Up",
#                          :href => R(ContextWiki::Controllers::Users, :new))
                          :href => '/users/new')
        update("li.session a").with(
                          self => "Log in",
#                          :href => R(ContextWiki::Controllers::Sessions, :new))
                          :href => "/sessions/new")
        remove("li.users")
      end
    end
  end

  module KnownUserViews
    include Manipulation
    def _navigation_links(&context)
      manipulate(context) do
        update("li.session a").with self => "Log Out"
      end
    end
  end
  register NoKnownUserViews => ContextR::NoKnownUserLayer,
           KnownUserViews   => ContextR::KnownUserLayer
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
  register KnownUserHelpers => ContextR::KnownUserLayer
end
