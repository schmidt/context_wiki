module ContextWiki::Views
  module NoEditorViews
    def _page_show_footer
      @receiver << @receiver.capture do
        yield
      end.gsub(/<li class="(delete|edit)">.*?<\/li>/, "")
    end

    def page_list
      @receiver << @receiver.capture do
        yield
      end.gsub(/<p class="(create)">.*?<\/p>/, "")
    end
  end
  register NoEditorViews => ContextR::NoEditorLayer
end

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
