module ContextWiki::Views
  in_layer :no_known_user do
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

  in_layer :known_user do
    include Manipulation
    def _navigation_links(&context)
      manipulate(context) do
        update("li.session a").with text => "Log Out"
      end
    end
  end
end

module ContextWiki::Helpers 
  in_layer :known_user do
    include Manipulation
    def footer(&context)
      append(context) do
        text " &middot; "
        text "Actions for #{state.current_user}"
      end
    end
  end
end
