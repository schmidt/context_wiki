module ContextWiki::Helpers
  in_layer :random do
    include Manipulation

    def footer(&context)
      append(context) do
        text " &middot; Random actions"
      end
    end
  end
end
