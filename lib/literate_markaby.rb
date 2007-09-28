require "ruby2ruby"

module LiterateMarkaby
  def self.included(base)
    base.const_get(:Mab).class_eval do
      def tag!(*g,&b)
        super
      end
    end
    base.const_get(:Helpers).class_eval do
      def ruby_code(*args, &block)
        self.pre do
          self.code(block.to_ruby.gsub(/^proc \{\n(.*)\n\}$/m, '\1'), *args)
        end
        block.call
      end
    end
  end
end
