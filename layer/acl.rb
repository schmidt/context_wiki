module ContextWiki
# Description of :admin layer
  module Views
    in_layer :admin do
      include Manipulation

      def footer(&context)
        append(context) do
          text " &middot; Admin actions"
        end
      end
    end
  end
# Description of no_admin layer
  #
  # Restrict access in to Controllers
  class Controllers::Groups
    in_layer :no_admin do
      self.extend(UnAuthorized)

      restrict_access(:all, :disallow)
    end
  end
  class Controllers::Users
    in_layer :no_admin do
      self.extend(UnAuthorized)

      restrict_access(:get, :disallow => '/edit$/')
      restrict_access(:put, :allow => '/^current$/')
      restrict_access(:delete, :disallow)
    end
  end

  # Remove functionality in Models
  class Models::User
    in_layer :no_admin do
      def update_groups(new_groups = nil)
      end
    end
  end

  # Remove links in Views
  module Views
    in_layer :no_admin do
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
  end


# Description of :editor layer
  module Helpers 
    in_layer :editor do
      include Manipulation

      def footer(&context)
        append(context) do
          text " &middot; Editor actions"
        end
      end
    end
  end

# Description of :no_editor layer
  #
  # Restrict access in to Controllers
  class Controllers::Pages
    in_layer :no_editor do
      self.extend(UnAuthorized)

      restrict_access(:get, :disallow => '/(edit|new)\/?$/')
      restrict_access(:post, :disallow)
      restrict_access(:put, :disallow)
      restrict_access(:delete, :disallow)
    end
  end

  # Remove links in Views
  module Views 
    in_layer :no_editor do
      include Manipulation

      def _page_show_footer(&context)
        manipulate(context) do
          remove("li.edit")
          remove("li.delete")
        end
      end

      def page_list(&context)
        manipulate(context) do
          remove("p.create")
        end
      end
    end
  end

# Description of :known_user layer
  module Views
    in_layer :known_user do
      include Manipulation
      def _navigation_links(&context)
        manipulate(context) do
          update("li.session a").with text => "Log Out"
        end
      end
    end
  end
  module Helpers 
    in_layer :known_user do
      include Manipulation
      def footer(&context)
        append(context) do
          text " &middot; Actions for #{state.current_user}"
        end
      end
    end
  end

# Description of :no_known_user layer
  #
  # Restrict access in to Controllers
  class Controllers::Users
    in_layer :no_known_user do
      self.extend(UnAuthorized)

      restrict_access(:get, :allow => '/^new$/')
      restrict_access(:put, :disallow)
    end
  end
  # Remove/Change links in Views
  module Views
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
  end
end
