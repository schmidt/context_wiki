module ContextWiki::Helpers
  module EditorHelpers
    def footer
      @receiver.capture do
        yield 
      end + @receiver.capture do
        text " &middot; "
        text "Editor actions"
      end
    end
  end
  register EditorHelpers => ContextR::EditorLayer
end
