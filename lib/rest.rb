module REST
  def service(*a)
    if @method == 'post' && (input._verb == 'put' || input._verb == 'delete')
      @env['REQUEST_METHOD'] = input._verb.upcase
      @method = input._verb
    end
    super(*a)
  end

  module Controllers
    def REST(name)
      name = name.downcase
      klass = R "/#{name}/", 
        "/#{name}/([^\/]+)", 
        "/#{name}/([^\/]+)/([^\/]+)"
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
    end
  end
end
