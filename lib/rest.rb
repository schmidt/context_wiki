require "action_controller/mime_type" 
module REST
  def service(*a)
    if @method == 'post' && (input._verb == 'put' || input._verb == 'delete')
      @env['REQUEST_METHOD'] = input._verb.upcase
      @method = input._verb
    end
    @format = read_accept_header
    if a[-2] == "." and self.class.ancestors.include? SleepingBag
      @format = read_format_extension(a.pop)
      a.pop
    end
    super(*a)
  end

  def read_format_extension(extension)
    select_one_of_accepted_mime_types([Mime::EXTENSION_LOOKUP[extension]])
  end

  def read_accept_header
    format = select_one_of_accepted_mime_types(
                          Mime::Type.parse(@env['HTTP_ACCEPT'] || ""))
    format = :css if format == :"text/css"
    format
  end

  def select_one_of_accepted_mime_types(accepted_mime_types)
    accepted_mime_types.empty? ? :all : accepted_mime_types.first.to_sym
  end

  module Controllers
    def REST(name)
      name = name.downcase
      klass = R "/#{name}/",                                    # 0
                "/#{name}/([^\/\\.]+)",                         # 1
                "/#{name}/([^\/\\.]+)/([^\/\\.]+)",             # 2
                "/#{name}(\\.)([^\/\\.]+)",                     # 2 -> 0
                "/#{name}/([^\/\\.]+)(\\.)([^\/]+)",            # 3 -> 1
                "/#{name}/([^\/\\.]+)/([^\/\\.]+)(\\.)([^\/]+)" # 4 -> 2
      klass.send(:include, SleepingBag)
      klass
    end
  end

  def self.included(modul)
    modul.const_get("Controllers").extend(Controllers)
    modul.const_get("Helpers").module_eval do
      define_method :http_verb do |verb|
        input :type => "hidden", :value => verb.downcase, :name => "_verb"
      end

      define_method :RF do |c, format, *g|
        url = R(c, *g)

        parts = url.split("?")
        parts[0] = parts.first[0...-1] if parts.first.ends_with?("/")
        parts.first << "." << format
        parts.join("?")
      end
    end
  end
end
