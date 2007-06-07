require 'sleeping_bag'

Camping.goes :Hiking

module Hiking::Controllers
  class Trails < R '/trails', '/trails/([^\/]+)', '/trails/([^\/]+)/([^\/]+)'
    include SleepingBag
  
    def index; "index" end
    def create; "create" end
    def new; "new" end
    def show(id); "show #{id}" end
    def edit(id); "edit #{id}" end
    def destroy(id); "destroy #{id}" end
    def update(id); "update #{id}" end
    
    methods[:search] = [:get, :post]
    def search; "search" end
    
    standard_actions << :just_the_facts
    methods[:just_the_facts] = [:head]
    def just_the_facts; "..." end
  end
end