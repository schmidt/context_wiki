module ContextWiki
  module Views::NoEditorViews; in_layer :no_editor
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

  module Helpers::EditorHelpers; in_layer :editor
    include Manipulation

    def footer(&context)
      append(context) do
        text " &middot; "
        text "Editor actions"
      end
    end
  end
end

