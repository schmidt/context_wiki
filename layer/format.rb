class ContextWiki::Controllers::Pages
  in_layer :xml_request do 
    self.extend(RESTModels)
    specify_domain_model(:name => "versions",
                         :model => "@page.versions")
  end
end

module ContextWiki::Base
  def render(m)
    super
  end

  in_layer :xml_request do
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
end
