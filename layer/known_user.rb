module ContextWiki
  module Views::NoKnownUserViews; in_layer :no_known_user
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

  module Views::KnownUserViews; in_layer :known_user
    include Manipulation
    def _navigation_links(&context)
      manipulate(context) do
        update("li.session a").with text => "Log Out"
      end
    end
  end

  module Helpers::KnownUserHelpers; in_layer :known_user
    include Manipulation
    def footer(&context)
      append(context) do
        text " &middot; "
        text "Actions for #{state.current_user}"
      end
    end
  end
end
