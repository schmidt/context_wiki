#!/usr/bin/env ruby
(%w{rubygems redcloth camping camping/db camping/session mime/types} + 
 %w{acts_as_versioned contextr md5}).each{ |lib| require lib }

require File.dirname(__FILE__) + '/../ext/sleeping_bag/sleeping_bag'

Camping.goes :ContextWiki

module ContextLogging
  def service(*a)
    t1 = Time.now
    s = super(*a)
    t2 = Time.now
    puts(["\"#{t1.to_formatted_s(:short)}\"",
          "%.2fs" % (t2 - t1),
          env["PATH_INFO"],
          "(%s)" % ContextR::layer_symbols.join(", ")].join(" - "))
    s
  end
end

module ContextCamping
  include ContextLogging
  def compute_current_context
    layers = []
    layers << :random if rand(0).round.zero?
    if @state.current_user
      layers << :known_user
      @current_user = @state.current_user
      @current_user.groups.each do | group |
        layers << group.name.singularize.to_sym
      end
    end
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

module Camping::Session
  attr_reader :state
end

module ContextWiki
  include Camping::Session, ContextCamping, REST 
  Mab.set(:indent, 4)
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

    def password_required?
      hashed_password.blank? || !password.blank?
    end

    def hash_password
      self.hashed_password = User.build_hash(password) unless password.blank?
    end

    def to_s
      self.name
    end

    def self.authenticate(name, password)
      User.find_by_name_and_hashed_password(name, self.build_hash(password))
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

    def to_s
      self.name
    end
  end
  class Page < Base
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"

    acts_as_versioned

    validates_uniqueness_of :name
    validates_format_of     :name, :with => /^[a-zA-Z0-9\-\.\_\~\!\*\'\(\)\+]+$/
    validates_length_of       :name, :within => 2..50
    validates_presence_of     :markup
    validates_presence_of     :user_id
    validates_numericality_of :rights
    validates_inclusion_of    :rights, :in => 0..0x777

    def to_s
      self.name
    end
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
        t.column :user_id,  :string, :limit => 25, :null => false
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
  class Users < REST('users')
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

  class Groups < REST('groups')
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

  class Sessions <  REST('sessions')
    # GET /sessions
    def index
      unless @state.current_user.nil?
        @current_user = User.find(@state.current_user)
      else
        @current_user = nil
      end
      render "session_list"
    end

    # GET /sessions/new
    def new
      render "session_create"
    end

    # POST /sessions
    def create
      @current_user = User.authenticate(input.session.name, 
                                        input.session.password)
      @state.current_user = @current_user unless @current_user.nil?
      if @current_user.nil?
        @error = true
        render "session_create"
      else
        render "session_list"
      end
    end

    # DELETE /sessions/(id)
    def destroy(id)
      @current_user = nil
      @state.current_user = @current_user 
      render "session_list"
    end
  end

  class Pages < REST('pages')
    # GET /pages
    def index
      @pages = Page.find(:all, :limit => 20)
      render "page_list"
    end

    # GET /pages/(id)
    def show(id)
      @page = Page.find_by_name(id)
      render "page_show"
    end

    # GET /pages/new
    def new
      @page = Page.new()
      render "page_create"
    end
    # PUT /pages
    def create
      @page = Page.new(input.page)
      @page.name = input.page.name.underscore
      @page.rights ||= 0x777
      @page.user = state.current_user
      if @page.valid?
        @page.save
        render "page_show"
      else
        render "page_create"
      end
    end

    # GET /pages/(id)/edit
    def edit(id)
      @page = Page.find_by_name(id)
      render "page_edit"
    end
    # PUT /pages/(id)
    def update(id)
      @page = Page.find_by_name(id)
      @page.update_attributes(input.page)
      if @page.valid?
        @page.save
        render "page_show"
      else
        render "page_edit"
      end
    end

    # DELETE /pages/(id)
    def destroy(id)
      Page.delete_all(:name => id)
      @pages = Page.find(:all, :limit => 20)
      render "page_list"
    end
  end

  class Index < R '/'
    def get
      render "index"
    end

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
    xhtml_strict do
      head do
        link :rel => 'stylesheet',
             :type => 'text/css',
             :href => '/static/stylesheets/application.css',
             :media => 'screen'
        title "ContextWiki :: Camping Wiki using ContextR"
      end
      body do 
        div.container! do
          div.head! do
            h1 "ContextWiki :: Camping Wiki using ContextR"
          end
          div.body! do
            div.content! do
              self << yield
            end
            div.navigation! do
              ul.basic_navigation! do
                li { a "Index", :href => R(Index) }
                li { a "Pages", :href => R(Pages) }
                li { a "Users", :href => R(Users) }
                li { a "Groups", :href => R(Groups) }
                li { a "Sessions", :href => R(Sessions) }
              end
            end
          end
          div.foot! do
            footer
          end
        end
      end
    end
  end

  def index
    p "Welcome to our shiny, tiny wiki system."
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
            td { a user.id, :href => R(Users, user.id) } 
            td user.std_markup
            td user.created_at
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
          p do
            http_verb("delete")
            input :type => "submit", :value => "Delete"
            text " this operation may not be reverted!"
          end
        end
      end
      li { a "Back to list", :href => R(Users) }
    end
  end

  def user_create
    form :action => R(Users), :method => :post do
      errors_for @user

      p do
        label "Name", :for => "user_name"
        br
        input :name => 'user[name]', :id => 'user_name', 
              :type => 'text', :value => @user.name
      end

      p do
        label "Password", :for => "user_password"
        br
        input :name => 'user[password]', :id => 'user_password', 
              :type => 'password'
      end

      p do
        label "Password Confimation", :for => "user_password_confirmation"
        br
        input :name => 'user[password_confirmation]', 
              :id => 'user_password_confirmation', :type => 'password'
      end 

      p do
        label "Email", :for => "user_email"
        br
        input :name => 'user[email]', :id => 'user_email', 
              :type => "text", :value => @user.email
      end

      p do
        input :type => 'submit', :value => 'Create Account'
        text " "
        a "Back", :href => R(Users)
      end
    end
  end

  def user_edit
    form :action => R(Users, @user.id), :method => :post do
      errors_for @user

      p do
        http_verb "put"

        label "Password", :for => "user_password"
        br
        input :name => 'user[password]', :id => 'user_password', 
              :type => 'password'
      end
      
      p do
        label "Password Confimation", :for => "user_password_confirmation"
        br
        input :name => 'user[password_confirmation]', 
              :id => 'user_password_confirmation', :type => 'password'
      end

      p do
        label "Email", :for => "user_email"
        br
        input :name => 'user[email]', :id => 'user_email', 
              :type => "text", :value => @user.email
      end

      fieldset do
        legend "Group Memberships"
        @groups.each do | group |
          p do
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
          end
        end
      end

      p do
        input :type => 'submit', :value => 'Change settings'
        text " "
        a "Back", :href => R(Users, @user.name)
      end
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
            td { a group.name , :href => R(Groups, group.name) } 
            td group.group_memberships.size
            td group.created_at
          end
        end
      end
    end
    p { a "Create new group", :href => R(Groups, "new") }
  end

  def group_create
    form :action => R(Groups), :method => :post do
      errors_for @group

      p do
        label "Name", :for => "group_name"
        br
        input :name => 'group[name]', :id => 'group_name', 
              :type => 'text', :value => @group.name
      end

      p do
        input :type => 'submit', :value => 'Create Group'
        text " "
        a "Back", :href => R(Groups)
      end
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
          http_verb("delete")
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
        p do
          http_verb("delete")
          input :type => "submit", :value => "Log out"
        end
      end
    else
      p "You are not logged in."
      p { a "Log in", :href => R(Sessions, :new) }
    end
  end

  def session_create
    p "Wrong user name or password. Please try again." if @error
    form :action => R(Sessions), :method => "post" do
      p do
        label "User name", :for => "session_name"
        br
        input :type => "text", :name => "session[name]", :id => "session_name"
      end

      p do
        label "Password", :for => "session_password"
        br
        input :type => "password", :name => "session[password]", 
              :id => "session_password"
      end

      p { input :type => "submit", :value => "Log in" }
    end
  end

  #################
  # Page Related Views
  def page_list
    table do
      thead do 
        tr do
          th "name"
          th "revision"
          th "owner"
          th "rights"
          th "markup"
        end
      end
      tbody do
        @pages.each do | page |
          tr do
            td { a page.name , :href => R(Pages, page.name) } 
            td { page.version }
            td { page.user }
            td { "%x" % page.rights }
            td { page.markup }
          end
        end
      end
    end
    p { a "Create new page", :href => R(Pages, "new") }
  end

  def page_show
    h2 @page.name.titleize
    div.wiki_content do
      @page.content
    end
    ul do
      li { a "Edit", :href => R(Pages, @page.name, :edit) }
      li do
        form :action => R(Pages, @page.name), :method => "post" do
          p do
            http_verb("delete")
            input :type => "submit", :value => "Delete"
            text " this operation may not be reverted!"
          end
        end
      end
      li { a "Back to list", :href => R(Pages) }
    end
  end

  def page_create
    form :action => R(Pages), :method => "post" do
      errors_for(@page)

      p do
        label "Name", :for => "page_name"
        br
        input :name => 'page[name]', :id => 'page_name', 
              :type => 'text', :value => @page.name
      end

      _page_form

      p do 
        input :type => "submit", :value => "Create Page"
        text " "
        a "Back", :href => R(Pages)
      end
    end
  end

  def page_edit
    form :action => R(Pages, @page.name), :method => "post" do
      http_verb "put"
      errors_for(@page)

      p do
        label "Name", :for => "page_name"
        br
        strong @page.name
      end

      _page_form

      p do 
        input :type => "submit", :value => "Change Page"
        text " "
        a "Back", :href => R(Pages)
      end
    end
  end

  def _page_form
    fieldset do
      legend "Markup"
      ["HTML", "Markaby", "Markdown"].each do | markup |
        p do
          options = {:name => 'page[markup]', 
                     :id => "page_markup_#{markup.downcase}", 
                     :type => 'radio', :value => markup}
          if (@page.markup.nil? and markup == "HTML") or 
              @page.markup == markup
            options[:checked] = "checked"
          end

          input(options)
          label markup, :for => "page_markup_#{markup.downcase}"
        end
      end
    end

    p do
      label "Content", :for => "page_content"
      br
      textarea :name => 'page[content]', :id => 'page_content' do
        text @page.content
      end
    end
  end
end

module ContextWiki::Helpers
  def footer 
    text "Basic actions"
  end
  module KnownUserHelpers
    def footer
      @receiver.capture do
        yield
      end + @receiver.capture do
        text " &middot; "
        text "Actions for #{state.current_user}"
      end
    end
  end
  module EditorHelpers
    def footer
      @receiver.capture do
        yield 
      end + @receiver.capture do
        text " &middot; "
        text "Editor actions"
      end
    end
  end
  module AdminHelpers
    def footer
      @receiver.capture do
        yield
      end + @receiver.capture do
        text " &middot; "
        text "Admin actions"
      end
    end
  end
  module RandomHelpers
    def footer
      @receiver.capture do
        yield
      end + @receiver.capture do
        text " &middot; "
        text "Random actions"
      end
    end
  end
  register RandomHelpers => ContextR::RandomLayer,
           EditorHelpers => ContextR::EditorLayer,
           AdminHelpers => ContextR::AdminLayer,
           KnownUserHelpers => ContextR::KnownUserLayer
end

def ContextWiki.create  
  ContextWiki::Models.create_schema :assume => 
        (ContextWiki::Models::Page.table_exists? ? 1.0 : 0.0)
end
