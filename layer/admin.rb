class ContextWiki::Models::User
  module NoAdminUserModel
    def update_groups(new_groups = nil)
    end
  end
  include NoAdminUserModel => :no_admin
end

module ContextWiki::Views
  module NoAdminViews
    include Manipulation
    def _user_show_footer(&context)
      manipulate(context) do
        remove("li.edit")
        remove("li.delete")
      end
    end

    def _group_memberships
    end

    def _navigation_links(&context)
      manipulate(context) do
        remove("li.groups")
      end
    end
  end
  include NoAdminViews => :no_admin
end

module ContextWiki::Helpers
  module AdminHelpers
    include Manipulation

    def footer(&context)
      append(context) do
        text " &middot; "
        text "Admin actions"
      end
    end
  end
  include AdminHelpers   => :admin
end
