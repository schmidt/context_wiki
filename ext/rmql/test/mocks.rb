class Foto < ActiveRecord::Base
  attr_accessor :title
  
  def initialize
    title = "Foto 1"
  end
end

class Excluded < ActiveRecord::Base
  exclude_from_rmql
  
  def initialize
  end
  
  def self.find( *args )
    [Excluded.new]
  end
end

class OnlySomeMethod < ActiveRecord::Base
  rmql_methods :only => [:only]
  
  def initialize
  end
  
  def self.find( *args )
    [OnlySomeMethod.new]
  end
  
  def only
    "yes"
  end
  
  def no
    "no"
  end
  
end

class ExceptSomeMethod < ActiveRecord::Base
  rmql_methods :exclude => [:except]
  
  def initialize
  end
  
  def self.find( *args )
    [ExceptSomeMethod.new]
  end
  
  def yes
    "yes"
  end
  
  def except
    "no"
  end
  
end

class OtherUser
end

class User < ActiveRecord::Base
  
  attr_accessor :name, :first_name
  
  def initialize( n, f)
    name = n
    first_name = f
  end

  # Find all fotos for this users
  def self.fotos( *args )
    [Foto.new]
  end
  
  # This is to simulate a 1:n relationship between
  # two models
  def fotos
    [Foto.new, Foto.new]
  end
  
  def self.find( *args )
    
    number = args.find {|e| e == :all}
    res = nil
    if number == :all
      res = [User.new("Lustig", "Peter")]
    end
    
    if c = args.find {|e| e == :conditions}
      if c.first = "name = 'Martin'"
        res = [User.new("Grund", "Martin")]
      elsif c.first = "first_name = 'Martin' and name = 'Grund'"
        res = [User.new("Grund", "and")]
      elsif c.first = "first_name = 'Martin' or name = 'Grund'"
        res = [User.new("Grund", "or")]
      elsif c.first = "first_name = 'Martin' and ( name = 'Grund' or 'Name = 'hase' )" 
        res = [User.new("Grund", "complex")]
      end
      
    end
    res
  end
  
  def first0_name
    "0Martin"
  end
    
end
