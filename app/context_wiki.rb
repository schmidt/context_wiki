#!/usr/bin/env ruby
(%w{rubygems redcloth camping camping/db camping/session mime/types} + 
 %w{acts_as_versioned contextr md5}).each{ |lib| require lib }

require File.dirname(__FILE__) + '/../ext/sleeping_bag/sleeping_bag'

Camping.goes :ContextWiki

module ContextCamping
  def compute_current_context
    layers = []
    layers << :random if rand(0).round.zero?
    layers << :known_user if @state.current_user
    layers
  end

  def service(*a)
    ContextR::with_layer *compute_current_context do
      @headers['x-contextr'] = ContextR::layer_symbols.join(" ")
      super(*a)
    end
  end
end

module REST
  def service(*a)
    if @method == 'post' && (input._verb == 'put' || input._verb == 'delete')
      @env['REQUEST_METHOD'] = input._verb.upcase
      @method = input._verb
    end
    super(*a)
  end
end

module Camping::Session
  attr_reader :state
end

module ContextWiki
  include Camping::Session, ContextCamping, REST
end

module ContextWiki::Models
  class User < Base
    set_primary_key :name
    has_many :group_memberships
    has_many :groups, :through => :group_memberships
    has_many :pages

    attr_accessor :password
    before_save :hash_password

    validates_presence_of :name, :email
    validates_uniqueness_of :name
    validates_length_of :name, :within => 2..25
    validates_format_of :name, :with => /[a-z]+/i
    validates_length_of :password, :within => 2..25, :if => :password_required?
    validates_confirmation_of :password,             :if => :password_required?
    validates_format_of :email, 
                  :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i

    def self.authenticate(name, password)
      User.find_by_name_and_hashed_password(name, self.build_hash(password))
    end

    def password_required?
      hashed_password.blank? || !password.blank?
    end

    def hash_password
      self.hashed_password = User.build_hash(password) unless password.blank?
    end

    def self.build_hash(string)
      MD5.hexdigest(string)
    end
  end
  class GroupMembership < Base
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"
    belongs_to :group, :class_name => "Group", :foreign_key => "group_id"
  end
  class Group < Base
    set_primary_key :name
    has_many :group_memberships
    has_many :users, :through => :group_memberships
    has_many :pages

    validates_length_of :name, :within => 2..25
    validates_format_of :name, :with => /[a-z]+/i
  end
  class Page < Base
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
        t.column :name,            :string,  :limit => 25,      :null => false
        t.column :hashed_password, :string,  :limit => 32,      :null => false
        t.column :email,           :string,  :limit => 255,     :null => false
        t.column :std_markup,      :string,  :limit => 10
        t.column :authenticated,   :boolean, :default => false, :null => false
        t.column :created_at,      :timestamp
        t.column :updated_at,      :timespamp
      end
      add_index :contextwiki_users, :name, :unique => true

      create_table :contextwiki_group_memberships, 
                   :id => false, :force => true do | t |
        t.column :group_id, :string, :limit => 25, :null => false
        t.column :user_id,  :string, :limit => 25, :null => false
      end
      add_index(:contextwiki_group_memberships, [:group_id, :user_id], 
                                                          :unique => true)

      create_table :contextwiki_groups, :id => false, :force => true do | t |
        t.column :name, :string, :limit => 25, :null => false
        t.column :created_at, :timestamp
        t.column :updated_at, :timespamp
      end
      add_index :contextwiki_groups, :name, :unique => true

      create_table :contextwiki_pages, :force => true do | t |
        t.column :name,     :string,  :limit => 50, :null => false
        t.column :content,  :text
        t.column :markup,   :string,  :limit => 10, :null => false
        t.column :group_id, :integer, :null => false
        t.column :user_id,  :integer, :null => false
        t.column :rights,   :integer
      end
      Page.create_versioned_table
      Page.reset_column_information

      Camping::Models::Session.create_schema
    end
    def self.down
      drop_table :contextwiki_users
      drop_table :contextwiki_group_memberships
      drop_table :contextwiki_groups
      drop_table :contextwiki_pages
      Page.drop_versioned_table
    end
  end

end

module ContextWiki::Controllers
  class Users < R '/users', '/users/([^\/]+)', '/users/([^\/]+)/([^\/]+)'
    include SleepingBag
    # GET /users
    def index
      @users = User.find(:all)
      render "user_list"
    end
    # GET /users/(id)
    def show(id)
      @user = User.find(id)
      render "user_show"
    end

    # GET /users/new
    def new
      @user = User.new
      render "user_create"
    end
    # POST /users
    def create
      @user = User.new(input.user)
      @user.id = input.user.name
      if @user.valid?
        @user.save
        render "user_show"
      else
        render "user_create"
      end
    end

    # GET /users/(id)/edit
    def edit(id)
      @user = User.find(id)
      @groups = Group.find(:all)
      render "user_edit"
    end

    # PUT /users/(id)
    def update(id)
      @user = User.find(id)
      new_groups = input.user.delete("groups").to_a.collect do | group_name |
        Group.find(group_name)
      end
      old_groups = @user.groups
      (new_groups - old_groups).each do | group |
        @user.groups << group
      end
      (old_groups - new_groups).each do | group |
        y(:group_id => group.id, :user_id => @user.id)
        GroupMembership.delete_all(:group_id => group.id,
                                    :user_id => @user.id)
      end
      @user.attributes = input.user
      if @user.valid?
        @user.save
        render "user_show"
      else
        render "user_edit"
      end
    end

    # DELETE /users/(id)
    def destroy(id)
      @user = User.find(id)
      @user.destroy
      @users = User.find(:all)
      render "user_list"
    end
  end

  class Groups < R '/groups', '/groups/([^\/]+)', '/groups/([^\/]+)/([^\/]+)'
    include SleepingBag
    # GET /group
    def index
      @groups = Group.find(:all)
      render "group_list"
    end

    # GET /groups/new
    def new
      @group = Group.new
      render "group_create"
    end
    # POST /groups
    def create
      @group = Group.new(input.group)
      @group.id = input.group.name
      if @group.valid?
        @group.save
        render "group_show"
      else
        render "group_create"
      end
    end

    # GET /groups/(id)
    def show(id)
      @group = Group.find(id)
      render "group_show"
    end

    # DELETE /groups/(id)
    def destroy(id)
      @group = Group.find(id)
      @group.destroy
      @groups = Group.find(:all)
      render "group_list"
    end
  end

  class Sessions <  R '/sessions', 
                      '/sessions/([^\/]+)', 
                      '/sessions/([^\/]+)/([^\/]+)'
    include SleepingBag
    def index
      unless @state.current_user.nil?
        @current_user = User.find(@state.current_user)
      else
        @current_user = nil
      end
      render "session_list"
    end
    def new
      render "session_create"
    end
    def create
      @current_user = User.authenticate(input.session.name, 
                                        input.session.password)
      @state.current_user = @current_user.id unless @current_user.nil?
      if @current_user.nil?
        @error = true
        render "session_create"
      else
        render "session_list"
      end
    end
    def destroy(id)
      @current_user = nil
      @state.current_user = @current_user 
      render "session_list"
    end
  end

  class Pages < R '/pages', '/pages/([^\/]+)', '/pages/([^\/]+)/([^\/]+)'
  end

  class Index < R '/'
    def get
      "Basic action"
    end

    module KnownUserMethods
      def get
        yield + "<br />" + "Actions for #{@receiver.state.current_user}"
      end
    end
    module RandomMethods
      def get
        yield + "<br />" + "Random action"
      end
    end

    register RandomMethods => ContextR::RandomLayer,
             KnownUserMethods => ContextR::KnownUserLayer
  end

  class Static < R '/static/(.+)'         
    PATH = File.expand_path(File.dirname(__FILE__) + "/../")

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

  def user_list
    table do
      thead do 
        tr do
          th "name"
          th "std markup"
          th "created at"
        end
      end
      tbody do
        @users.each do | user |
          tr do
            th { a user.id, :href => R(Users, user.id) } 
            th user.std_markup
            th user.created_at
          end
        end
      end
    end
    p { a "Create new user", :href => R(Users, "new") }
  end

  def user_show
    dl do
      dt "Name"
      dd @user.name

      dt "Email"
      dd @user.email

      dt "Created at"
      dd @user.created_at

      dt "Updated at"
      dd @user.updated_at
    end
    ul do
      li { a "Edit", :href => R(Users, @user.id, :edit) }
      li do
        form :action => R(Users, @user.id), :method => "post" do
          input :type => "hidden", :name => "_verb", :value => "delete"
          input :type => "submit", :value => "Delete"
          text " this operation may not be reverted!"
        end
      end
      li { a "Back to list", :href => R(Users) }
    end
  end

  def user_create
    form :action => R(Users), :method => :post do
      errors_for @user

      label "Name", :for => "user_name"
      br
      input :name => 'user[name]', :id => 'user_name', 
            :type => 'text', :value => @user.name
      br

      label "Password", :for => "user_password"
      br
      input :name => 'user[password]', :id => 'user_password', 
            :type => 'password'
      br
      label "Password Confimation", :for => "user_password_confirmation"
      br
      input :name => 'user[password_confirmation]', 
            :id => 'user_password_confirmation', :type => 'password'
      br

      label "Email", :for => "user_email"
      br
      input :name => 'user[email]', :id => 'user_email', 
            :type => "text", :value => @user.email
      br

      input :type => 'submit', :value => 'Create Account'
    end
  end

  def user_edit
    form :action => R(Users, @user.id), :method => :post do
      errors_for @user

      input :type => "hidden", :name => "_verb", :value => "put"

      label "Password", :for => "user_password"
      br
      input :name => 'user[password]', :id => 'user_password', 
            :type => 'password'
      br
      label "Password Confimation", :for => "user_password_confirmation"
      br
      input :name => 'user[password_confirmation]', 
            :id => 'user_password_confirmation', :type => 'password'
      br

      label "Email", :for => "user_email"
      br
      input :name => 'user[email]', :id => 'user_email', 
            :type => "text", :value => @user.email
      br

      fieldset do
        legend "Group Memberships"
        @groups.each do | group |
          if @user.groups.include?(group)
            input :type => "checkbox", :name => "user[groups]",
                  :value => "#{group.name}",
                  :id => "user_groups_#{group.name}", :checked => "checked"
          else
            input :type => "checkbox", :name => "user[groups]",
                  :value => "#{group.name}",
                  :id => "user_groups_#{group.name}"
          end
          label group.name, :for => "user_groups_#{group.name}"
          br
        end
      end

      input :type => 'submit', :value => 'Change settings'
    end
  end

  #########################
  # Group Related Views
  def group_list
    table do
      thead do 
        tr do
          th "name"
          th "no. of users"
          th "created at"
        end
      end
      tbody do
        @groups.each do | group |
          tr do
            th { a group.name , :href => R(Groups, group.name) } 
            th group.group_memberships.size
            th group.created_at
          end
        end
      end
    end
    p { a "Create new group", :href => R(Groups, "new") }
  end

  def group_create
    form :action => R(Groups), :method => :post do
      errors_for @group

      label "Name", :for => "group_name"
      br
      input :name => 'group[name]', :id => 'group_name', 
            :type => 'text', :value => @group.name
      br

      input :type => 'submit', :value => 'Create Group'
    end
  end

  def group_show
    dl do
      dt "Name"
      dd @group.name

      dt "Created at"
      dd @group.created_at

      dt "Updated at"
      dd @group.updated_at
    end
    ul do
      li do
        form :action => R(Groups, @group.id), :method => "post" do
          input :type => "hidden", :name => "_verb", :value => "delete"
          input :type => "submit", :value => "Delete"
          text " this operation may not be reverted!"
        end
      end
      li { a "Back to list", :href => R(Groups) }
    end
  end


  #################
  # Session Related Views
  def session_list
    if @current_user
      p do
        text "You are successfully logged in."
        text "Your user name is "
        em(@current_user.name)
        text "."
      end
      form :action => R(Sessions, @current_user.id), :method => "post" do
        input :type => "hidden", :name => "_verb", :value => "delete"
        input :type => "submit", :value => "Log out"
      end
    else
      p "You are not logged in."
      p { a "Log in", :href => R(Sessions, :new) }
    end
  end

  def session_create
    p "Wrong user name or password. Please try again." if @error
    form :action => R(Sessions), :method => "post" do
      label "User name", :for => "session_name"
      br
      input :type => "text", :name => "session[name]", :id => "session_name"
      br

      label "Password", :for => "session_password"
      br
      input :type => "password", :name => "session[password]", 
            :id => "session_password"
      br

      input :type => "submit", :value => "Log in"
    end

  end
end

def ContextWiki.create  
  ContextWiki::Models.create_schema :assume => 
        (ContextWiki::Models::Page.table_exists? ? 1.0 : 0.0)
end
