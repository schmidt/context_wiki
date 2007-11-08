module ContextWiki::Helpers::RandomHelpers; in_layer :random
  include Manipulation

  def footer(&context)
    append(context) do
      text " &middot; "
      text "Random actions"
    end
  end
end
