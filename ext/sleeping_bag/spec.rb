require 'rubygems'
require 'test/spec'

require 'camping'
require 'camping/reloader'

Camping::Reloader.new('hiking.rb')

context "SleepingBag" do
  specify "standard paths and methods should map correctly" do
    fixtures = {
      %w( GET /trails ) => 'index',
      %w( POST /trails ) => 'create',
      %w( GET /trails/new ) => 'new',
      %w( GET /trails/2 ) => 'show 2',
      %w( PUT /trails/2 ) => 'update 2',
      %w( DELETE /trails/2 ) => 'destroy 2',
      %w( GET /trails/2/edit ) => 'edit 2'
    }
    
    fixtures.each do |request, result|
      Hiking.run(StringIO.new, {
        'HTTP_HOST' => '', 'SCRIPT_NAME' => '', 'HTTP_COOKIE' => '',
        'PATH_INFO' => request[1], 'REQUEST_METHOD' => request[0]
      }).body.to_s.should.equal result
    end
  end
  
  specify "we can use custom actions and more than one method with a path" do
    fixtures = {
      %w( GET /trails/search ) => 'search',
      %w( POST /trails/search ) => 'search'
    }
    
    fixtures.each do |request, result|
      Hiking.run(StringIO.new, {
        'HTTP_HOST' => '', 'SCRIPT_NAME' => '', 'HTTP_COOKIE' => '',
        'PATH_INFO' => request[1], 'REQUEST_METHOD' => request[0]
      }).body.to_s.should.equal result
    end
  end
  
  specify "and HEAD as well, on the bare collection URL" do
    fixtures = {
      %w( HEAD /trails ) => '...'
    }
    
    fixtures.each do |request, result|
      Hiking.run(StringIO.new, {
        'HTTP_HOST' => '', 'SCRIPT_NAME' => '', 'HTTP_COOKIE' => '',
        'PATH_INFO' => request[1], 'REQUEST_METHOD' => request[0]
      }).body.to_s.should.equal result
    end
  end
  
  specify "sleeping bag stuff shouldn't be public" do
    Hiking::Controllers::Trails.public_instance_methods.should.not.include "not_found"
    Hiking::Controllers::Trails.public_instance_methods.should.not.include "dispatch"
  end
  
  specify "we shouldn't be able to call http verbs as aspects" do
    Hiking::Controllers::Trails.collection_actions.should.not.include :get
    Hiking::Controllers::Trails.member_actions.should.not.include :get
    
    fixtures = {
      %w( GET /trails/lewis_and_clark/get ) => '<h1>Not found</h1>'
    }
    
    fixtures.each do |request, result|
      Hiking.run(StringIO.new, {
        'HTTP_HOST' => '', 'SCRIPT_NAME' => '', 'HTTP_COOKIE' => '',
        'PATH_INFO' => request[1], 'REQUEST_METHOD' => request[0]
      }).body.to_s.should.equal result
    end
  end
end