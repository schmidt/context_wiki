module ContextWiki::Views
  module NoEditorViews
    def _page_show_footer
      yield(:receiver) << yield(:receiver).capture do
        yield(:next)
      end.gsub(/<li class="(delete|edit)">.*?<\/li>/, "")
    end

    def page_list
      yield(:receiver) << yield(:receiver).capture do
        yield(:next)
      end.gsub(/<p class="(create)">.*?<\/p>/, "")
    end
  end
  register NoEditorViews => ContextR::NoEditorLayer
end

module ContextWiki::Helpers
  module EditorHelpers
    def footer
      yield(:receiver).capture do
        yield(:next)
      end + yield(:receiver).capture do
        text " &middot; "
        text "Editor actions"
      end
    end
  end
  register EditorHelpers => ContextR::EditorLayer
end
