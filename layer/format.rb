class ContextWiki::Controllers::Pages
  module XMLMethods
    def get(*a)
      if a[1] == "versions"
        class << yield(:receiver)
          def model
            @page.versions
          end
        end
      end
      yield(:next, *a)
    end
  end
  register XMLMethods => ContextR::XmlRequestLayer
end
module ContextWiki::Base
  def render(m)
    super
  end
  module XMLMethods
    def render(m)
      model = fetch_model(yield(:receiver))
      yield(:receiver).instance_variable_get(:@headers)["Content-Type"] = 
        "application/xml"
      model.nil? ? "" : model.to_xml
    end

    def fetch_model(receiver)
      if receiver.respond_to?(:model)
        receiver.model
      else
        likely_model_name = fetch_controller_name(receiver)

        instance_vars = receiver.instance_variables
        instance_vars.delete_if{ |var_name| 
              var_name != "@#{likely_model_name.singularize}" and
              var_name != "@#{likely_model_name}" }
        model = instance_vars.collect{ |var_name|
              receiver.instance_variable_get(var_name) 
        }.select{ |var|
              var.respond_to? :to_xml
        }.first
      end
    end

    def fetch_controller_name(receiver)
      receiver.class.name.scan(/([^:]+)$/).first.first.downcase
    end
  end
  register XMLMethods => ContextR::XmlRequestLayer
end
