module ContextWiki
  module Models::User::NoAdminUserModel; in_layer :no_admin
    def update_groups(new_groups = nil)
    end
  end

  module Views::NoAdminViews; in_layer :no_admin
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

  module Helpers::AdminHelpers; in_layer :admin
    include Manipulation

    def footer(&context)
      append(context) do
        text " &middot; "
        text "Admin actions"
      end
    end
  end
end
