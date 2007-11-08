module ContextWiki::Controllers
  module RMQL::NoAdminMethods; in_layer :no_admin
    self.extend(UnAuthorized)

    restrict_access(:all, :disallow)
  end
  module Groups::NoAdminMethods; in_layer :no_admin
    self.extend(UnAuthorized)

    restrict_access(:all, :disallow)
  end
  module Users::NoAdminMethods; in_layer :no_admin
    self.extend(UnAuthorized)

    restrict_access(:get, :disallow => '/edit$/')
    restrict_access(:put, :allow => '/^current$/')
    restrict_access(:delete, :disallow)
  end

  module Pages::NoEditorMethods; in_layer :no_editor
    self.extend(UnAuthorized)

    restrict_access(:get, :disallow => '/(edit|new)\/?$/')
    restrict_access(:post, :disallow)
    restrict_access(:put, :disallow)
    restrict_access(:delete, :disallow)
  end

  module Users::NoKnownUserMethods; in_layer :no_known_user
    self.extend(UnAuthorized)

    restrict_access(:get, :allow => '/^new$/')
    restrict_access(:put, :disallow)
  end
end
