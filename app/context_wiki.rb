#!/usr/bin/env ruby
(%w{rubygems redcloth camping camping/db camping/session mime/types} + 
 %w{acts_as_versioned contextr md5}).each{ |lib| require lib }

Camping.goes :ContextWiki

module ContextCamping
  def compute_current_context
    layers = []
    layers << :random if rand(0).round.zero?
    layers << :knownuser if @state.user_id
    layers
  end

  def service(*a)
    ContextR::with_layer *compute_current_context do
      @headers['x-contextr'] = ContextR::layer_symbols.join(" ")
      super(*a)
    end
  end
end

module ContextWiki
  include Camping::Session, ContextCamping
end

module ContextWiki::Models
  class User < Base
    set_primary_key :name
    has_many :group_memberships
    has_many :groups, :through => :group_memberships

    validates_length_of :name, :within => 2..25
    validates_format_of :name, :with => /a-z/
  end
  class GroupMembership < Base
    belongs_to :user
    belongs_to :group
  end
  class Group < Base
    set_primary_key :name
    has_many :group_memberships
    has_many :users, :through => :group_memberships

    validates_length_of :name, :within => 2..25
    validates_format_of :name, :with => /a-z/
  end
  class Wiki < Base
    set_primary_key :name
    has_many :wiki_pages
    belongs_to :user
    belongs_to :group

    validates_length_of :name, :within => 2..25
    validates_format_of :name, :with => /^[a-zA-Z0-9\-\.\_\~\!\*\'\(\)\+]+$/
    validates_presence_of     :user_id
    validates_presence_of     :group_id
    validates_numericality_of :rights
    validates_inclusion_of    :rights, :in => 0..0x777
  end
  class WikiPage < Base
    belongs_to :wiki
    belongs_to :user
    belongs_to :group

    acts_as_versioned

    validates_uniqueness_of :name, :sope => :wiki_id
    validates_format_of     :name, :with => /^[a-zA-Z0-9\-\.\_\~\!\*\'\(\)\+]+$/
    validates_length_of       :name, :within => 2..25
    validates_presence_of     :markup
    validates_presence_of     :user_id
    validates_presence_of     :group_id
    validates_numericality_of :rights
    validates_inclusion_of    :rights, :in => 0..0x777
  end

  class CreateContextWiki < V 1.0
    def self.up
      create_table :contextwiki_users, :id => false, :force => true do | t |
        t.column :name,          :string,  :limit => 25,      :null => false
        t.column :password,      :string,  :limit => 32,      :null => false
        t.column :email,         :string,  :limit => 255,     :null => false
        t.column :std_markup,    :string,  :limit => 10
        t.column :authenticated, :boolean, :default => false, :null => false
        t.column :created_at, :timestamp
        t.column :updated_at, :timespamp
      end
      add_index :contextwiki_users, :name, :unique => true

      create_table :contextwiki_group_memberships, 
                   :id => false, :force => true do | t |
        t.column :group_id, :integer, :null => false
        t.column :user_id,  :integer, :null => false
      end
      add_index(:contextwiki_group_memberships, [:group_id, :user_id], 
                                                          :unique => true)

      create_table :contextwiki_groups, :id => false, :force => true do | t |
        t.column :name, :string, :limit => 25, :null => false
        t.column :created_at, :timestamp
        t.column :updated_at, :timespamp
      end
      add_index :contextwiki_groups, :name, :unique => true

      create_table :contextwiki_wikis, :id => false, :force => true do | t |
        t.column :name,     :string,  :limit => 25, :null => false
        t.column :group_id, :integer, :null => false
        t.column :user_id,  :integer, :null => false
        t.column :rights,   :integer
        t.column :created_at, :timestamp
        t.column :updated_at, :timespamp
      end
      add_index :contextwiki_wikis, :name, :unique => true

      create_table :contextwiki_wiki_pages, :force => true do | t |
        t.column :name,     :string,  :limit => 50, :null => false
        t.column :content,  :text
        t.column :markup,   :string,  :limit => 10, :null => false
        t.column :group_id, :integer, :null => false
        t.column :user_id,  :integer, :null => false
        t.column :rights,   :integer
      end
      WikiPage.create_versioned_table
      WikiPage.reset_column_information

      Camping::Models::Session.create_schema
    end
    def self.down
      drop_table :contextwiki_users
      drop_table :contextwiki_group_memberships
      drop_table :contextwiki_groups
      drop_table :contextwiki_wikis
      drop_table :contextwiki_wiki_pages
      WikiPages.drop_versioned_table
    end
  end

end

module ContextWiki::Controllers
  class Index < R '/'
    def get
      "some"
    end

    module RandomMethods
      def get
        "else"
      end
    end
    register RandomMethods => ContextR::RandomLayer
  end

  class Static < R '/static/(.+)'         
    MIME_TYPES = {'.css' => 'text/css', 
                  '.js' => 'text/javascript', 
                  '.jpg' => 'image/jpeg'}
    PATH = File.expand_path(File.dirname(__FILE__))

    def get(file)
      if file.include? '..'
        @status = "403"
        "403 - Invalid path"
      else
        path = File.join(PATH, 'static', file)
        type = MIME::Types.type_for(path)[0].to_s || '/text/plain'
        @headers['Content-Type'] = type
        @headers['X-Sendfile'] = path
      end
    end
  end
end

module ContextWiki::Views
  def layout
    html do
      head do
        link :rel => 'stylesheet',
             :type => 'text/css',
             :href => '/static/stylesheets/application.css',
             :media => 'screen'
        title "ContextWiki :: Camping Wiki using ContextR"
      end
      body do 
        self << yield
      end
    end
  end
end

def ContextWiki.create  
  ContextWiki::Models.create_schema :assume => 
        (ContextWiki::Models::WikiPage.table_exists? ? 1.0 : 0.0)
end
