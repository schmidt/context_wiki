module MaRuKu
  Globals[:execute] = false
  Globals[:attach_output] = false

  module Out::HTML
    unless instance_methods.include? "to_html_code_using_pre_with_literate"
      def to_html_code_using_pre_with_literate(source)
        if get_setting(:execute)
          return_value = LiterateSandbox.module_eval(source)
          source += "\n>> #{return_value}" if get_setting(:attach_output)
        end
        to_html_code_using_pre_without_literate(source) 
      end

      alias_method :to_html_code_using_pre_without_literate,
                   :to_html_code_using_pre
      alias_method :to_html_code_using_pre, 
                   :to_html_code_using_pre_with_literate
    end
  end
end
module LiterateSandbox
  extend self
end
