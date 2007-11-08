module ContextWiki
  class Models::User
    in_layer :no_admin do
      def update_groups(new_groups = nil)
      end
    end
  end

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

    in_layer :admin do
      include Manipulation

      def footer(&context)
        append(context) do
          text " &middot; "
          text "Admin actions"
        end
      end
    end
  end
end
