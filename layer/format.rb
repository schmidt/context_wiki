module ContextWiki::Base
  def render(m)
   super 
  end

  module XMLMethods
    def render(*args)
      puts "Here we go in XML yeah"
      model = fetch_model(yield(:receiver))
      yield(:receiver).instance_variable_get(:@headers)["Content-Type"] = "application/xml"
      model.nil? ? "" : model.to_xml
    end

    def fetch_model(receiver)
      instance_vars = receiver.instance_variables
      controller_name = fetch_controller_name(receiver)
      instance_vars.delete_if{ |var_name| 
            var_name != "@#{controller_name.singularize}" and
            var_name != "@#{controller_name}" }
      model = instance_vars.collect{ |var_name|
            receiver.instance_variable_get(var_name) 
      }.select{ |var|
            var.respond_to? :to_xml
      }.first
    end

    def fetch_controller_name(receiver)
      receiver.class.name.scan(/([^:]+)$/).first.first.downcase
    end
  end
  register XMLMethods => ContextR::XmlRequestLayer
end
