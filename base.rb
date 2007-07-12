
%w{rubygems redcloth camping camping/db camping/session mime/types
   acts_as_versioned contextr md5}.each{ |lib| require lib }

%w{sleeping_bag lilu}.each { |ext| 
    require File.dirname(__FILE__) + "/ext/#{ext}/lib/#{ext}" }

%w{general context_camping rest renderer}.each { |lib| 
    load(File.dirname(__FILE__) + "/lib/#{lib}.rb") }
