require "maruku"
module ContextWiki
  module Renderer
    module BasicRenderMethods
      def render(markup)
        raise NotImplementedError, "Subclass Responsibility"
      end
    end

    class HTML
      module ClassMethods
        include BasicRenderMethods
        def render(markup)
          markup
        end
      end
      self.extend(ClassMethods)
    end

    class Markaby
      module ClassMethods
        include BasicRenderMethods
        def render(markup)
          mab = Mab.new({}, self)
          mab.capture do
            eval(markup)
          end
        end
      end
      self.extend(ClassMethods)
    end

    class Markdown
      module ClassMethods
        include BasicRenderMethods
        def render(markup)
          Maruku.new(markup).to_html
        end
      end
      self.extend(ClassMethods)
    end
  end

  RENDERER = { :html => ContextWiki::Renderer::HTML,
               :markaby => ContextWiki::Renderer::Markaby,
               :markdown => ContextWiki::Renderer::Markdown }

  module Helpers
    def renderer
      RENDERER.keys.collect(&:to_s).sort
    end
  end
end
