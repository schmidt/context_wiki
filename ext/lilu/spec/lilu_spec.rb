require File.dirname(__FILE__) + '/../lib/lilu'
require 'ostruct'
describe "Newly created ", Lilu::Renderer do

  before(:each) do
    @instructions = "remove('html')"
    @html_source = "<html></html>"
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
  end

  it "should load instructions" do
    @renderer.instructions.should == @instructions
  end

  it "should load html source" do
    @renderer.html_source.should == @html_source
  end
end

describe "Newly created ", Lilu::Renderer, " with local assignments" do

  before(:all) do
    @test_variable = "Lilu"
  end

  { "binding" => lambda {|s| s.instance_eval "binding" },
    "Hash with variable names without @ prefix" => { "test_variable" => "Lilu" },
    "Hash with variable names with @ prefix" => { "@test_variable" => "Lilu" },
    "Object with instance variables" => Object.new.instance_eval { @test_variable = "Lilu" ; self}
     }.each_pair do |name, val|
    it "should load instance variable from #{name}" do
      @instructions = "remove('html')"
      @html_source = "<html></html>"
      val = val.call(self) if val.is_a?(Proc) # hack to support binding test
      @renderer = Lilu::Renderer.new(@instructions,@html_source,val)
      @renderer.instance_variable_get(:@test_variable).should == @test_variable
    end
  end
end

describe Lilu::Renderer do

  %w[update populate remove use replace].each do |verb|
    it "should raise an exception if element is not found when using #{verb} verb" do
      @instructions = %{#{verb}("#some-missing-data") }
      @html_source = %{<div id="some-data">Lola</div>}
      @renderer = Lilu::Renderer.new(@instructions,@html_source)
      lambda { @renderer.apply }.should raise_error(Lilu::ElementNotFound)
    end
  end

  it "should remove element on remove(path) construct" do
    @instructions = %{remove("#some-data") }
    @html_source = %{<div id="some-data">Lola</div>}
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    Hpricot(@renderer.apply).at("#some-lilu-data").should be_nil
  end

  it "should remove all elements on remove(:all,path) construct" do
    @instructions = %{remove(:all,".not-for-public") }
    @html_source = %{<div class="not-for-public">Lola</div><br /><div class="not-for-public">1</div>}
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    Hpricot(@renderer.apply).to_s.should == "<br />"
  end


  it "should update element details on update(path).with(String) construct" do
    @instructions = %{update("#some-data").with("Lilu")}
    @html_source = %{<div id="some-data">Lola</div>}
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    Hpricot(@renderer.apply).at("#some-data").inner_html.should == "Lilu"
  end

  it "should update element details on update(path).with Hash construct" do
    @instructions = %{update("#some-data").with :id => "some-lilu-data", "a" => { :href => "/", self => "is here" }   }
    @html_source = %{<div id="some-data">Lola <a href="#">is there</a></div>}
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    result.at("#some-lilu-data").inner_html.should == "Lola <a href=\"/\">is here</a>"
  end
  
  

  it "should populate element details on populate(path).for(:each,@blogs) { block }  construct" do
    @blogs = [OpenStruct.new(:url => "http://railsware.com", :blog_id => 1, :name => "Railsware"),OpenStruct.new(:url => "http://railsware.com/", :blog_id => 2, :name => "Railsware!")]
    @instructions = %{populate("#blog-example").for(:each,@blogs) {|blog| mapping 'a' => {:href => blog.url, self => blog.name}, :id => blog.blog_id } }
    @html_source = %{<ul id="blogs"><li id="blog-example"><a href="#">My Blog</a></li></ul>}
    @renderer = Lilu::Renderer.new(@instructions,@html_source,self)
    result = Hpricot(@renderer.apply)
    result.at("#blogs/#2/a")[:href].should == "http://railsware.com/"
    result.at("#blogs/#1/a").inner_html.should == "Railsware"
    result.at("#blogs/#blog-example").should be_nil
    li_items = result.search("li")
    li_items.first[:id].should == "1"
    li_items.last[:id].should == "2"
  end

  it "should populate element details on populate(:all,path).for(:each,@blogs) { block }  construct" do
    @blogs = [OpenStruct.new(:url => "http://railsware.com", :blog_id => 1, :name => "Railsware")]
    @instructions = %{populate(:all,".blog-example").for(:each,@blogs) {|blog| mapping 'a' => {:href => blog.url, self => blog.name}, :id => blog.blog_id } }
    @html_source = %{<ul id="blogs1"><li id="blog-example" class="blog-example"><a href="#">My Blog</a></li></ul><ul id="blogs2"><li id="blog-example" class="blog-example"><a href="#">My Blog</a></li></ul>}
    @renderer = Lilu::Renderer.new(@instructions,@html_source,self)
    result = Hpricot(@renderer.apply)
    result.at("#blogs1/#1/a")[:href].should == "http://railsware.com"
    result.at("#blogs1/#1/a").inner_html.should == "Railsware"
    result.at("#blogs1/#blog-example").should be_nil
    result.at("#blogs2/#1/a")[:href].should == "http://railsware.com"
    result.at("#blogs2/#1/a").inner_html.should == "Railsware"
    result.at("#blogs2/#blog-example").should be_nil

  end

  it "should update all elements, matched by path on update(:all, path).with Hash construct" do
    @instructions = %{update(:all, "a").with :href => "#", self => 'Stay here'}
    @html_source = %{<a href="http://java.net">C'mon, Java!</a><a href="http://www.php.net">Go away!</a>}
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    (result/"a").each { |elem| elem.inner_html.should == 'Stay here'; elem[:href].should == '#' }
  end

  it "should update all elements, matched by path on update(:all, path).with Hash construct, taking in account each element content" do
    @instructions = 'update(:all, "a").with :href => L{"#{element[:href]}/download"}, self => L{"Download #{element.inner_html}"}'
    links =  {"http://java.net" => "C'mon, Java!", "http://www.php.net" => "Go away!"}
    @html_source = ""
    links.each_pair {|url,name| @html_source << %{<a href="#{url}">#{name}</a>} }
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    links.each_pair do |url,name|
      result.at("//a[@href='#{url}/download']").inner_html.should == "Download #{name}"
    end
  end

  it "should update all elements, matched by path on update(:all, path).with Block construct, taking in account each element content" do
    @instructions = 'update(:all, "a").with { mapping :href => "#{element[:href]}/download", self => "Download #{element.inner_html }" }'
    links =  {"http://java.net" => "C'mon, Java!", "http://www.php.net" => "Go away!"}
    @html_source = ""
    links.each_pair {|url,name| @html_source << %{<a href="#{url}">#{name}</a>} }
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    links.each_pair do |url,name|
      result.at("//a[@href='#{url}/download']").inner_html.should == "Download #{name}"
    end
  end

  it "should update all elements, matched by path on update(:all, path).with Lambda construct, taking in account each element content" do
    @instructions = 'update(:all, "a").with L{ mapping :href => "#{element[:href]}/download", self => "Download #{element.inner_html }" }'
    links =  {"http://java.net" => "C'mon, Java!", "http://www.php.net" => "Go away!"}
    @html_source = ""
    links.each_pair {|url,name| @html_source << %{<a href="#{url}">#{name}</a>} }
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    links.each_pair do |url,name|
      result.at("//a[@href='#{url}/download']").inner_html.should == "Download #{name}"
    end
  end

  it "should remove everything outside of specified element on use(path)" do
    @instructions = "use('#main')"
    @html_source = '<html><body><div id="main">Blablabla</div></body></html>'
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    result.to_s.should == '<div id="main">Blablabla</div>'
  end

  it "should raise ArgumentError if use is called with :all argument" do
    @instructions = "use(:all,'#main')"
    @html_source = '<html><body><div id="main">Blablabla</div></body></html>'
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    lambda { Hpricot(@renderer.apply) }.should raise_error(ArgumentError)
  end

  it "should replace element with another using replace().with String construct" do
    @instructions = "replace('#main').with 'Hello!'"
    @html_source = '<html><body><div id="main">Blablabla</div></body></html>'
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    result.to_s.should == '<html><body>Hello!</body></html>'
  end

  it "should replace element with another using replace().with Block construct" do
    @instructions = "replace('#main').with { 'Hello!' }"
    @html_source = '<html><body><div id="main">Blablabla</div></body></html>'
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    result.to_s.should == '<html><body>Hello!</body></html>'
  end

  it "should replace element with another using replace().with Lambda construct" do
    @instructions = "replace('#main').with  L{ 'Hello!' }"
    @html_source = '<html><body><div id="main">Blablabla</div></body></html>'
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    result.to_s.should == '<html><body>Hello!</body></html>'
  end

  it "should replace all elements with another using replace(:all,).with String construct" do
    @instructions = "replace(:all,'.main').with 'Hello!'"
    @html_source = '<html><body><div class="main">Blablabla</div><div class="main">Blublublu</div></body></html>'
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    result.to_s.should == '<html><body>Hello!Hello!</body></html>'
  end

  it "should replace all elements with another using replace(:all,).with String construct" do
    @instructions = "replace(:all,'.main').with 'Hello!'"
    @html_source = '<html><body><div class="main">Blablabla</div><div class="main">Blublublu</div></body></html>'
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    result.to_s.should == '<html><body>Hello!Hello!</body></html>'
  end

  it "should replace element with another using replace().with Element construct" do
    @instructions = "replace('#main').with element_at('#helper')"
    @html_source = '<html><body><div id="main">Blablabla</div><div id="helper">Lilu</div></body></html>'
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    result.to_s.should == '<html><body><div id="helper">Lilu</div></body></html>'
  end

  it "should replace all elements with another using replace(:all,).with Element construct" do
    @instructions = "replace(:all,'.main').with element_at('#helper')"
    @html_source = '<html><body><div class="main">Blablabla</div><div class="main">Blublublua</div><div id="helper">Lilu</div></body></html>'
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    result = Hpricot(@renderer.apply)
    result.to_s.should == '<html><body><div id="helper">Lilu</div></body></html>'
  end

end

describe Lilu::Populate do
  it "should send for(missed_name,*args) on a missed_name(*args)" do
    populate = Lilu::Populate.new(nil,Lilu::Renderer.new(nil,""))
    [:each,:any].each do |sym|
      populate.should_receive(:for).with(sym,anything(),anything(),anything())
      populate.send sym, 1,2,3
    end
  end
end


###########
# My extensions

describe "Newly created ", Lilu::Renderer do
  before(:each) do
    @instructions = lambda do
      remove('html')
    end
    @html_source = "<html></html>"
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
  end

  it "should load instructions" do
    @renderer.instructions.should == @instructions
  end

  it "should load html source" do
    @renderer.html_source.should == @html_source
  end

  %w[update populate remove use replace].each do |verb|
    it "should raise an exception if element is not found when using #{verb} verb" do
      @instructions = eval(%{lambda do #{verb}("#some-missing-data") end})
      @html_source = %{<div id="some-data">Lola</div>}
      @renderer = Lilu::Renderer.new(@instructions,@html_source)
      lambda { @renderer.execute }.should raise_error(Lilu::ElementNotFound)
    end
  end

  it "should remove element on remove(path) construct" do
    @instructions = lambda do remove("#some-data") end
    @html_source = %{<div id="some-data">Lola</div>}
    @renderer = Lilu::Renderer.new(@instructions,@html_source)
    Hpricot(@renderer.execute).at("#some-lilu-data").should be_nil
  end
end
