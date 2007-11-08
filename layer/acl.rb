module ContextWiki::Controllers
  class RMQL
    in_layer :no_admin do
      self.extend(UnAuthorized)

      restrict_access(:all, :disallow)
    end
  end
  class Groups
    in_layer :no_admin do
      self.extend(UnAuthorized)

      restrict_access(:all, :disallow)
    end
  end
  class Users
    in_layer :no_admin do
      self.extend(UnAuthorized)

      restrict_access(:get, :disallow => '/edit$/')
      restrict_access(:put, :allow => '/^current$/')
      restrict_access(:delete, :disallow)
    end
  end

  class Pages
    in_layer :no_editor do
      self.extend(UnAuthorized)

      restrict_access(:get, :disallow => '/(edit|new)\/?$/')
      restrict_access(:post, :disallow)
      restrict_access(:put, :disallow)
      restrict_access(:delete, :disallow)
    end
  end

  class Users
    in_layer :no_known_user do
      self.extend(UnAuthorized)

      restrict_access(:get, :allow => '/^new$/')
      restrict_access(:put, :disallow)
    end
  end
end
