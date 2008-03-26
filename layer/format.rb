class ContextWiki::Controllers::Pages
  in_layer :json_request do 
    self.extend(RESTModels)
    specify_domain_model(:name => "versions",
                         :model => "@page.versions")
  end
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

  module ModelGuessing
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

  in_layer :xml_request do
    include ModelGuessing

    def render(m)
      model = fetch_model(yield(:receiver))
      yield(:receiver).instance_variable_get(:@headers)["Content-Type"] = 
        "application/xml"
      model.nil? ? "" : model.to_xml
    end
  end

  in_layer :json_request do
    include ModelGuessing

    def render(m)
      model = fetch_model(yield(:receiver))
      yield(:receiver).instance_variable_get(:@headers)["Content-Type"] = 
        "text/plain"
        "application/json"
      model.nil? ? "" : model.to_json
    end
  end

  in_layer :atom_request do
    def render(m)
      if m == "page_latest"
        yield(:receiver).instance_variable_get(:@headers)["Content-Type"] = 
          "application/atom+xml"
        super
      else
        ContextR::without_layer :atom_request do
          super(m)
        end
      end
    end
  end

  in_layer :rss_request do
    def render(m)
      if m == "page_latest"
        yield(:receiver).instance_variable_get(:@headers)["Content-Type"] = 
          "application/rss+xml" 
        super
      else
        ContextR::without_layer :rss_request do
          super(m)
        end
      end
    end
  end
end

module ContextWiki::Views
  in_layer :atom_request do
    def layout 
      yield(:block!)
    end

    def page_latest
      pages = yield(:receiver).instance_variable_get(:@pages)
      root = yield(:receiver).instance_eval { URL(Index) }.to_s.gsub("/","")
      page_url = lambda do |*params|
        "http://" + root + yield(:receiver).instance_eval { R(Pages, *params) }
      end

      xml = Builder::XmlMarkup.new
      xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      xml.feed "xmlns" => 'http://www.w3.org/2005/Atom' do 

        xml.title "ContextWiki Latest Changes - Atom" 

        xml.link 'rel' => 'self', 'type' => 'application/atom+xml',
                 'href' => page_url["latest", "atom"]
        xml.link 'rel' => 'alternate', 'type' => 'text/html',
                 'href' => page_url["latest"]

        xml.updated pages.first.updated_at.xmlschema

        pages.each do |page|
          xml.entry do 
            xml.author do 
              xml.name(page.user)
            end
            xml.published page.updated_at.xmlschema
            xml.updated page.updated_at.xmlschema
            xml.link 'rel' => 'alternate',  'type' => 'text/html', 
                     'href' => page_url[page.name]
            xml.title page.name
            xml.summary page.rendered_content, 'type' => 'html'
          end
        end

      end
    end

    def nil?; false; end
  end
end

module ContextWiki::Views
  in_layer :rss_request do
    def layout 
      yield(:block!)
    end

    def page_latest
      pages = yield(:receiver).instance_variable_get(:@pages)
      root = yield(:receiver).instance_eval { URL(Index) }.to_s.gsub("/","")
      page_url = lambda do |page|
        "http://" + root + yield(:receiver).instance_eval { R(Pages, page) }
      end

      xml = Builder::XmlMarkup.new
      xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      xml.rss(:version=>"2.0") do
        xml.channel do
          xml.title('ContextWiki Latest Changes - RSS 2.0')
          xml.link(page_url['latest'])
          xml.description('ContextWiki Latest Changes')

          pages.each do |page|
            xml.item do
              xml.title(page.name)
              xml.link(page_url[page.name])
              xml.pubDate(page.updated_at)
              xml.author(page.user)
              xml.description(page.rendered_content)
            end
          end
        end
      end
    end

    def nil?; false; end
  end
end
