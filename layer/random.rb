module ContextWiki::Helpers
  in_layer :random do
    include Manipulation

    def footer(&context)
      append(context) do
        text " &middot; "
        text "Random actions"
      end
    end
  end
end
