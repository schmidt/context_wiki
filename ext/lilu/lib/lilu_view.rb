require File.dirname(__FILE__) + '/lilu'
module Lilu
  class View
    def initialize(view)
      @view = view
    end
    def render(template, local_assigns = {})
      lilu_file_path = local_assigns[:lilu_file_path]
      local_assigns.delete :lilu_file_path
      @view.instance_eval do
        local_assigns.merge!("content_for_layout" => @content_for_layout,"controller" => @controller,"___view" => self)
        Lilu::Renderer.new(template,IO.read(lilu_file_path.gsub(/#{File.extname(lilu_file_path)}$/,'.html')),@assigns.merge(local_assigns)).apply
      end
    end
  end
end