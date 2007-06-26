class ContextWiki::Controllers::Groups
  module NoAdminMethods
    self.extend(UnAuthorized)

    restrict_access(:all, :disallow)
  end
  register NoAdminMethods => ContextR::NoAdminLayer
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

  register NoAdminMethods => ContextR::NoAdminLayer
  register NoKnownUserMethods => ContextR::NoKnownUserLayer
end

class ContextWiki::Controllers::Pages
  module NoEditorMethods
    self.extend(UnAuthorized)

    restrict_access(:get, :disallow => '/(edit|new)\/?$/')
    restrict_access(:post, :disallow)
    restrict_access(:put, :disallow)
    restrict_access(:delete, :disallow)
  end

  register NoEditorMethods => ContextR::NoEditorLayer
end
