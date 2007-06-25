class ContextWiki::Controllers::Groups
  module NoAdminMethods
    %w{get post put delete}.each do | method_name |
      define_method method_name.to_sym do | *a |
        @receiver.instance_eval do
          @status = 401
          "test"
          render "not_authorized"
        end
      end
    end
  end
  register NoAdminMethods => ContextR::NoAdminLayer
end
class ContextWiki::Controllers::Users
  module NoAdminMethods
    %w{delete}.each do | method_name |
      define_method method_name.to_sym do | *a |
        @receiver.instance_eval do
          @status = 401
          "test"
          render "not_authorized"
        end
      end
    end
  end
  register NoAdminMethods => ContextR::NoAdminLayer
end
class ContextWiki::Controllers::Pages
  module NoAdminMethods
    %w{delete}.each do | method_name |
      define_method method_name.to_sym do | *a |
        @receiver.instance_eval do
          @status = 401
          "test"
          render "not_authorized"
        end
      end
    end
  end
  register NoAdminMethods => ContextR::NoAdminLayer
end

module ContextWiki::Views
  module NoAdminViews
    def _navigation_links
      @receiver.capture do
        yield
      end.gsub( @receiver.capture do
        li { a "Groups", :href => R(ContextWiki::Controllers::Groups) }
      end, "")
    end
    def _authenticated_box
      ""
    end
  end
  register NoAdminViews => ContextR::NoAdminLayer
end

module ContextWiki::Helpers
  module AdminHelpers
    def footer
      @receiver.capture do
        yield
      end + @receiver.capture do
        text " &middot; "
        text "Admin actions"
      end
    end
  end
  register AdminHelpers   => ContextR::AdminLayer
end
