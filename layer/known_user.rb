module ContextWiki::Views
  module NoKnownUserViews
    def _navigation_links
      @receiver << @receiver.capture do
        yield
      end.sub(/<li class="profile">.*?<\/li>/, @receiver.capture do
        li.signup { a "Sign up", 
                      :href => R(ContextWiki::Controllers::Users, :new) }
      end).sub(/<li class="session">.*?<\/li>/, @receiver.capture do
        li.login  { a "Log in",
                      :href => R(ContextWiki::Controllers::Sessions, :new) }
      end).sub(/<li class="users">.*?<\/li>/, "")
    end
  end

  module KnownUserViews
    def _navigation_links
      @receiver << @receiver.capture do
        yield
      end.gsub(/Session/, "Log out")
    end
  end
  register NoKnownUserViews => ContextR::NoKnownUserLayer,
           KnownUserViews   => ContextR::KnownUserLayer
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
