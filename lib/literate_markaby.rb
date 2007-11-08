require "ruby2ruby"

module LiterateMarkaby
  STRIP_PROC = /^proc \{\n(.*)\n\}$/m
  def self.included(base)
    base.const_get(:Mab).class_eval do
      def tag!(*g,&b)
        super
      end
    end
    base.const_get(:Helpers).class_eval do
      def ruby_code(&block)
        self.pre do
          self.code(block.to_ruby.gsub(STRIP_PROC, '\1'))
        end
        block.call
      end
    end
  end
end
