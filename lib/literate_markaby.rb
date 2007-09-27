require "ruby2ruby"
module Markaby
  class Builder
    def ruby_code(*args, &block)
      self.pre(block.to_ruby.gsub(/^proc \{\n(.*)\n\}$/m, '\1'), *args)
      block.call
    end
  end
end

module LiterateMarkaby
  def self.included(base)
    base.const_get(:Mab).class_eval do
      def tag!(*g,&b)
        super
      end
    end
  end
end
