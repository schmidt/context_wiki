module ContextWiki::Views
  module NoKnownUserViews
    def _navigation_links
      yield(:receiver) << yield(:receiver).capture do
        yield(:next)
      end.sub(/<li class="profile">.*?<\/li>/, yield(:receiver).capture do
        li.signup { a "Sign up", 
                      :href => R(ContextWiki::Controllers::Users, :new) }
      end).sub(/<li class="session">.*?<\/li>/, yield(:receiver).capture do
        li.login  { a "Log in",
                      :href => R(ContextWiki::Controllers::Sessions, :new) }
      end).sub(/<li class="users">.*?<\/li>/, "")
    end
  end

  module KnownUserViews
    def _navigation_links
      yield(:receiver) << yield(:receiver).capture do
        yield(:next)
      end.gsub(/Session/, "Log out")
    end
  end
  register NoKnownUserViews => ContextR::NoKnownUserLayer,
           KnownUserViews   => ContextR::KnownUserLayer
end

module ContextWiki::Helpers
  module KnownUserHelpers
    def footer
      yield(:receiver).capture do
        yield(:next)
      end + yield(:receiver).capture do
        text " &middot; "
        text "Actions for #{state.current_user}"
      end
    end
  end
  register KnownUserHelpers => ContextR::KnownUserLayer
end
