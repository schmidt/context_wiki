module ContextWiki::Views
  module NoEditorViews
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
  register NoEditorViews => ContextR::NoEditorLayer
end

module ContextWiki::Helpers
  module EditorHelpers
    include Manipulation

    def footer(&context)
      append(context) do
        text " &middot; "
        text "Editor actions"
      end
    end
  end
  register EditorHelpers => ContextR::EditorLayer
end
