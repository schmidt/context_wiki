class ContextWiki::Controllers::RMQL
  module NoAdminMethods
    self.extend(UnAuthorized)

    restrict_access(:all, :disallow)
  end
  include NoAdminMethods => :no_admin
end

class ContextWiki::Controllers::Groups
  module NoAdminMethods
    self.extend(UnAuthorized)

    restrict_access(:all, :disallow)
  end
  include NoAdminMethods => :no_admin
end

class ContextWiki::Controllers::Users
  module NoAdminMethods
    self.extend(UnAuthorized)

    restrict_access(:get, :disallow => '/edit$/')
    restrict_access(:put, :allow => '/^current$/')
    restrict_access(:delete, :disallow)
  end
  module NoKnownUserMethods
    self.extend(UnAuthorized)

    restrict_access(:get, :allow => '/^new$/')
    restrict_access(:put, :disallow)
  end

  include NoAdminMethods => :no_admin
  include NoKnownUserMethods => :no_known_user
end

class ContextWiki::Controllers::Pages
  module NoEditorMethods
    self.extend(UnAuthorized)

    restrict_access(:get, :disallow => '/(edit|new)\/?$/')
    restrict_access(:post, :disallow)
    restrict_access(:put, :disallow)
    restrict_access(:delete, :disallow)
  end

  include NoEditorMethods => :no_editor
end
