require 'rubygems'
require 'mosquito'
require File.dirname(__FILE__) + "/../context_wiki"

ContextWiki.create
include ContextWiki::Models

class TestSession < Camping::FunctionalTest
  fixtures :contextwiki_users
end

class TestUser < Camping::UnitTest
  fixtures :contextwiki_users
end
