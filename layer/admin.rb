class ContextWiki::Models::User
  module NoAdminUserModel
    def update_groups(new_groups = nil)
    end
  end
  register NoAdminUserModel => ContextR::NoAdminLayer
end

module ContextWiki::Views
  module NoAdminViews
    def _user_show_footer
      yield(:receiver) << yield(:receiver).capture do
        yield(:next)
      end.gsub(/<li class="(edit|delete)">.*?<\/li>/, "")
    end

    def _group_memberships
    end

    def _navigation_links
      yield(:receiver) << yield(:receiver).capture do
        yield(:next)
      end.gsub(/<li class="groups">.*?<\/li>/, "")
    end

#    def _authenticated_box
#      ""
#    end
  end
  register NoAdminViews => ContextR::NoAdminLayer
end

module ContextWiki::Helpers
  module AdminHelpers
    def footer
      yield(:receiver).capture do
        yield(:receiver)
      end + yield(:receiver).capture do
        text " &middot; "
        text "Admin actions"
      end
    end
  end
  register AdminHelpers   => ContextR::AdminLayer
end
