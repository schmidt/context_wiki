#!/usr/bin/env ruby
$:.unshift(File.dirname(__FILE__))

%w{rubygems redcloth camping camping/db camping/session mime/types
   acts_as_versioned contextr md5}.each{ |lib| require lib }

%w{sleeping_bag lilu rmql}.each { |ext| 
    require "ext/#{ext}/lib/#{ext}" }

%w{general rest context_camping renderer
   literate_markaby literate_maruku}.each { |lib| load("lib/#{lib}.rb") }

Camping.goes :ContextWiki

module Camping::Session
  attr_reader :state
end


module ContextWiki
  include LiterateMarkaby
  include ContextCamping
  include REST
  include Camping::Session
end

module ContextWiki::Models
  class User < Base
    set_primary_key :name
    has_many :group_memberships
    has_many :groups, :through => :group_memberships
    has_many :pages

    attr_protected :name, :authenticated, :hashed_password

    attr_accessor :password
    before_save :hash_password

    validates_presence_of   :name, :email
    validates_uniqueness_of :name
    validates_exclusion_of  :name, :in => %w{new edit current}
    validates_length_of     :name, :within => 2..25
    validates_format_of     :name, :with => /[a-z]+/i
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

    def update_groups(new_groups = nil)
      new_groups = new_groups.to_a.collect do | group_name |
        Group.find(group_name)
      end
      old_groups = self.groups
      (new_groups - old_groups).each do | group |
        self.groups << group
      end
      (old_groups - new_groups).each do | group |
        GroupMembership.delete_all(:group_id => group.id,
                                    :user_id => self.id)
      end
      self.groups(:refresh)
    end

    def self.authenticate(name, password)
      User.find(:first, 
                :conditions => {:name =>name, 
                                :hashed_password => self.build_hash(password),
                                :authenticated => true})
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

    validates_length_of    :name, :within => 2..25
    validates_format_of    :name, :with => /[a-z]+/i
    validates_exclusion_of :name, :in => %w{new edit}

    def to_s
      self.name
    end
  end
  class Page < Base
    belongs_to :user, :class_name => "User", :foreign_key => "user_id"

    acts_as_versioned

    validates_uniqueness_of :name
    validates_format_of     :name, :with => /^[a-zA-Z0-9\-\.\_\~\!\*\'\(\)\+]+$/
    validates_length_of     :name, :within => 2..50
    validates_exclusion_of  :name, :in => %w{new edit latest}
    validates_presence_of   :markup
    validates_presence_of   :user_id

    def to_s
      self.name
    end

    def rendered_content
      ContextWiki::RENDERER[self.markup.to_sym].render(self.content)
    end

    def updated_at
      super || Time.now
    end

    def self.new_for_render(options)
      p = Page.new :content => options.content, :markup => options.markup
      p.name = options.name
      p
    end

    def self.copy_from_version(version)
      attributes = version.attributes
      attributes.delete("updated_at")
      attributes.delete("page_id")
      attributes.delete("id")
      attributes[:version] = version.version
      Page.new(attributes.merge(:versions => [version]))
    end

    def self.latest(count = 5)
      self.find(:all, :limit => count, 
                      :include => "versions", 
                      :order => "contextwiki_page_versions.updated_at DESC")
    end
  end

  class CreateContextWiki < V 1.0
    def self.up
      create_table :contextwiki_users, :id => false do | t |
        t.column :name,            :string,  :limit => 25,      :null => false
        t.column :hashed_password, :string,  :limit => 32,      :null => false
        t.column :email,           :string,  :limit => 255,     :null => false
        t.column :std_markup,      :string,  :limit => 10
        t.column :authenticated,   :boolean, :default => false, :null => false
        t.column :created_at,      :timestamp
        t.column :updated_at,      :timestamp
      end
      add_index :contextwiki_users, :name, :unique => true

      create_table :contextwiki_group_memberships, 
                   :id => false do | t |
        t.column :group_id, :string, :limit => 25, :null => false
        t.column :user_id,  :string, :limit => 25, :null => false
      end
      add_index(:contextwiki_group_memberships, [:group_id, :user_id], 
                                                          :unique => true)

      create_table :contextwiki_groups, :id => false do | t |
        t.column :name, :string, :limit => 25, :null => false
        t.column :created_at, :timestamp
        t.column :updated_at, :timestamp
      end
      add_index :contextwiki_groups, :name, :unique => true

      create_table :contextwiki_pages do | t |
        t.column :name,     :string,  :limit => 50, :null => false
        t.column :content,  :text
        t.column :markup,   :string,  :limit => 10, :null => false
        t.column :user_id,  :string, :limit => 25, :null => false
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
      @users = User.find(:all, :order => "name")
      render "user_list"
    end
    # GET /users/(id)
    def show(id)
      @user = User.find(id)
      render "user_show"
    rescue
      redirect R(Users)
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
      @user_id = @user.id 
      @groups = Group.find(:all)
      render "user_edit"
    rescue
      redirect R(Users)
    end

    # PUT /users/(id)
    def update(id)
      @user = User.find(id)
      @user.update_groups(input.user.delete("groups"))
      @user.attributes = input.user
      @user.authenticated = !!input.user.authenticated
      if @user.valid?
        @user.save
        state.current_user = @user if current_user?(@user)
        render "user_show"
      else
        render "user_edit"
      end
    rescue
      redirect R(Users)
    end

    # DELETE /users/(id)
    def destroy(id)
      @user = User.find(id)
      @user.destroy
      @users = User.find(:all, :order => "name")
      render "user_list"
    rescue
      redirect R(Users)
    end

    methods[:current] = [:get, :put]
    def current
      @groups = Group.find(:all)
      if @method == "put"
        current_user.update_groups(input.user.delete("groups"))
        current_user.attributes = input.user
        if current_user.valid?
          current_user.save
        end
      end
      @user = current_user
      @user_id = "current"
      render "user_edit"
    rescue
      redirect R(Users)
    end
  end

  class Groups < REST('groups')
    # GET /group
    def index
      @groups = Group.find(:all, :order => "name")
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
    rescue
      redirect R(Groups)
    end

    # DELETE /groups/(id)
    def destroy(id)
      @group = Group.find(id)
      @group.destroy
      @groups = Group.find(:all)
      render "group_list"
    rescue
      redirect R(Groups)
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
      @state.current_user = @current_user
      in_reset_context do
        if @current_user.nil?
          @error = true
          render "session_create"
        else
          render "session_list"
        end
      end
    end

    # DELETE /sessions/(id)
    def destroy(id)
      @current_user = nil
      @state.current_user = @current_user 
      in_reset_context do
        render "session_list"
      end
    end
  end

  class Pages < REST('pages')
    # GET /pages
    def index
      @pages = Page.find(:all, :order => "name")
      render "page_list"
    end

    # GET /pages/(id)
    def show(id)
      @page = Page.find_by_name(id)
      if @page.nil?
        @page = Page.new
        @page.name = id
        redirect R(Pages, id, :edit)
      elsif input.version
        @page = Page.copy_from_version(@page.find_version(input.version))
        render "page_show"
      else
        render "page_show"
      end
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
      @page.user = current_user

      if @page.update_attributes(input.page)
        render "page_show"
      else
        render "page_edit"
      end
    end

    # DELETE /pages/(id)
    def destroy(id)
      @page = Page.find_by_name(id)
      @page.destroy
      @pages = Page.find(:all, :order => "name")
      render "page_list"
    end

    # GET /pages/(id)/versions VERSIONS
    methods[:version] = [:get]
    def versions(id)
      @page = Page.find_by_name(id)
      render "page_versions"
    rescue
      redirect R(Pages)
    end

    # GET /pages/latest LATEST 
    methods[:latest] = [:get]
    def latest
      @pages = Page.latest(5)
      render "page_latest"
    rescue
      redirect R(Pages)
    end

    methods[:preview] = [:post]
    def preview
      @page = Page.new_for_render(input.page)
      render "_page_body"
    end
  end

  class RMQL < R '/rmql'
    def get
      form :method => "post" do
        textarea :name => "query", :id => "query" do
          text %Q{<users>
  for $user in user return <user>{$user/name}</user>
</users>}
        end
        input :type => "submit", :value => "Send"
      end
    end

    def post
      res = RMQLParser.parse(RMQLLexer.lex(input.query)) 
      if res.is_a? Dhaka::ParseErrorResult
        raise RMQLException.new("Error parsing query. Please check the syntax!")
      end
      @headers["Content-Type"] = "application/xml"
      RMQLEvaluator.new(nil).evaluate(res)
    end
  end

  class Index < R '/'
    def get
      redirect R(Pages, "index")
    end
  end

  class Static < R '/static/(.+)'         
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
    xhtml_strict do
      head do
        link :rel => 'stylesheet', :type => 'text/css',
             :href => '/static/stylesheets/application.css'

        link :rel => "alternate", :type => "application/rss+xml",
             :title => "Latest Changes - RSS", 
             :href => RF(Pages, "rss", "latest")

        link :rel => "alternate", :type => "application/atom+xml",
             :title => "Latest Changes - Atom", 
             :href => RF(Pages, "atom", "latest")

        title "ContextWiki :: Camping Wiki using ContextR"
        %w{prototype builder application}.each do | lib |
          script :type => "text/javascript", 
                 :src => "/static/javascripts/#{lib}.js"
        end
      end
      body do 
        div.menu! do
          ul.links! do
            _navigation_links
          end
          h3.title "ContextWiki :: Camping Wiki using ContextR"
        end
        div.fullpage! do
          div.pager! do
          end
          div.page_shade do
            div.page do
              self << yield
            end
          end
        end
        div.foot! do
          footer
        end
      end
    end
  end

  def user_list
    table do
      thead do 
        tr do
          th "name"
          th "std markup"
          th "authenticated"
          th "created at"
        end
      end
      tbody do
        @users.each do | user |
          tr do
            td { a user.id, :href => R(Users, user.id) } 
            td user.std_markup
            td(user.authenticated ? "yes" : "no" )
            td user.created_at.to_formatted_s(:db)
          end
        end
      end
    end
  end

  def user_show
    dl do
      dt "Name"
      dd @user.name

      dt "Email"
      dd @user.email

      dt "Standard Markup"
      dd @user.std_markup

      dt "Authenticated"
      dd(@user.authenticated ? "yes" : "no")

      dt "Created at"
      dd @user.created_at.to_formatted_s(:db)

      dt "Updated at"
      dd @user.updated_at.to_formatted_s(:db)
    end
    _user_show_footer
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

      _user_form

      p do
        input :type => 'submit', :class => "submit", :value => 'Create Account'
        text " "
        a "Back", :href => R(Users)
      end
    end
  end

  def user_edit
    form :action => R(Users, @user_id), :method => :post do
      errors_for @user

      div { http_verb "put" }
      
      _user_form
      _group_memberships

      p do
        input :type => 'submit', :class => "submit", :value => 'Change settings'
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
            td group.created_at.to_formatted_s(:db)
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
        input :type => 'submit', :class => "submit", :value => 'Create Group'
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
      dd @group.created_at.to_formatted_s(:db)

      dt "Updated at"
      dd @group.updated_at.to_formatted_s(:db)
    end
    ul.actions do
      li do
        form :action => R(Groups, @group.id), :method => "post" do
          div do
            http_verb("delete")
            input :type => "submit", :class => "submit", :value => "Delete"
            text " this operation may not be reverted!"
          end
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
        text "You are now logged in. Your user name is " 
        em(@current_user.name)
        text "."
      end
      form :action => R(Sessions, @current_user.id), :method => "post" do
        p do
          http_verb("delete")
          input :type => "submit", :class => "submit", :value => "Log out"
        end
      end
    else
      p "You are not logged in."
      p do 
        a "Log in", :href => R(Sessions, :new) 
      end
    end
  end

  def session_create
    p "Wrong user name or password. Please try again." if @error
    form :action => R(Sessions), :method => "post" do
      p do
        label "User name", :for => "session_name"
        br
        input :type => "text", :class => "text", :name => "session[name]", 
              :id => "session_name"
      end

      p do
        label "Password", :for => "session_password"
        br
        input :type => "password", :name => "session[password]", 
              :id => "session_password"
      end

      p { input :type => "submit", :class => "submit", :value => "Log in" }
    end
  end

  #################
  # Page Related Views
  def page_list
    table do
      thead do 
        tr do
          th "name"
          th "version"
          th "author"
          th "markup"
        end
      end
      tbody do
        @pages.each do | page |
          tr do
            td { a page.name , :href => R(Pages, page.name) } 
            td { page.version }
            td { page.user }
            td { page.markup }
          end
        end
      end
    end
    p.create { a "Create new page", :href => R(Pages, "new") }
  end

  def page_show
    _page_body
    dl.page_meta do
      dt "Author"
      dd @page.user

      dt "Version"
      dd @page.version

      dt "Last change"
      dd @page.versions.last.updated_at.to_formatted_s(:db)
    end
    _page_show_footer
  end

  def page_create
    form :action => R(Pages), :method => "post", :id => "page_form" do
      errors_for(@page)

      p do
        label "Name", :for => "page_name"
        br
        input :name => 'page[name]', :id => 'page_name', 
              :type => 'text', :value => @page.name
      end

      _page_form

      p.create do 
        input :type => "submit", :class => "submit", :value => "Create Page"
        text " "
        a "Back", :href => R(Pages)
      end

      div.preview! ""
    end
  end

  def page_edit
    form :action => R(Pages, @page.name), 
         :method => "post", :id => "page_form" do
      div { http_verb "put" }
      errors_for(@page)

      p do
        label "Name", :for => "page_name"
        br
        strong.page_name! @page.name
      end

      _page_form

      p do 
        input :type => "submit", :class => "submit", :value => "Change Page"
        text " "
        a "Back", :href => R(Pages, @page.name)
      end

      div.preview! ""
    end
  end

  def page_versions
    table do
      thead do 
        tr do
          th "version"
          th "owner"
          th "markup"
          th "updated at"
        end
      end
      tbody do
        @page.versions.each do | page |
          tr do
            td { a page.version , :href => R(Pages, page.name, 
                                             {:version => page.version}) } 
            td { page.user_id }
            td { page.markup }
            td { page.updated_at.to_formatted_s(:db) }
          end
        end
      end
    end
    p { a "Back to current version", :href => R(Pages, @page.name) }
  end

  def page_latest
    @page = @pages.shift
    page_show
    @pages.each do |page|
      @page = page
      hr
      page_show
    end
  end

  #############
  # Error related views
  def not_authorized
    h1 "Authorization Required"
    p "This server could not verify that you
    are authorized to access the document
    requested.  Either you supplied the wrong
    credentials (e.g., bad password), or your
    browser doesn't understand how to supply
    the credentials required."
  end

  #############
  # Partials
  def _user_show_footer
    ul.actions do
      li.edit { a "Edit", :href => R(Users, @user.id, :edit) }
      li.delete do
        form :action => R(Users, @user.id), :method => "post" do
          p do
            http_verb("delete")
            input :type => "submit", :class => "submit", :value => "Delete"
            text " this operation may not be reverted!"
          end
        end
      end
      li.list { a "Back to list", :href => R(Users) }
    end
  end

  def _user_form
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
            :type => "text", :class => "text", :value => @user.email
    end

    _authenticated_box

    fieldset do
      legend "Standard Markup"
      markup_choice((@user.std_markup || :html).to_s, "user", "std_markup")
    end
  end

  def _authenticated_box
    if @user_id != "current" and not @user.new_record? 
      options = { :type => "checkbox", :name => "user[authenticated]",
                  :value => "true", :id => "user_authenticated" }
      options[:checked] = "checked" if @user.authenticated
      p do
        input(options)
        label "Authenticated", :for => "user_authenticated"
      end
    end
  end

  def _group_memberships
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
  end

  def _page_body
    h2 @page.name.titleize
    div.wiki_content do
      @page.rendered_content
    end
  end

  def _page_show_footer
    ul.actions do
      li.edit { a "Edit", :href => R(Pages, @page.name, :edit) }
      li.others { a "Other Versions", :href => R(Pages, @page.name, :versions) }
      li.delete do
        form :action => R(Pages, @page.name), :method => "post" do
          p do
            http_verb("delete")
            input :type => "submit", :class => "submit", :value => "Delete"
            text " this operation may not be reverted!"
          end
        end
      end
      li.list { a "Back to list", :href => R(Pages) }
    end
  end

  def _page_form
    fieldset do
      legend "Markup"
      markup_choice((@page.markup || 
                     @current_user.try.std_markup || 
                     :html).to_s, "page", "markup")
    end

    p do
      label "Content", :for => "page_content"
      br
      textarea(:id => "page_content", 
               :name => 'page[content]' ) { @page.content }
    end
  end

  def _navigation_links
    li.index   { a "Index", :href => R(Index) }
    li.pages   { a "All Pages", :href => R(Pages) }
    li.groups  { a "All Groups", :href => R(Groups) }
    li.users   { a "All Users", :href => R(Users) }
    li.profile { a "My Profile (#{current_user.try.name})", 
                   :href => R(Users, :current) }
    li.session { a "Session", :href => R(Sessions) }
  end

end

module ContextWiki::Helpers
  def footer 
    div do
      text "Powered by "
      a "Camping", :href => "http://code.whytheluckystiff.net/camping/wiki"
      text " &middot; "
      a "SleepingBag", :href => "http://code.google.com/p/sleepingbag/"
      text " &middot; "
      a "ContextR", :href => "http://contextr.rubyforge.org/"
    end
    text "Basic actions"
  end

  def textarea(options)
    super(options.merge(:cols => 72, :rows => 25))
  end

  def markup_choice(default, var_name, field_name)
    renderer.each do | markup |
      p do
        options = {:name => "#{var_name}[#{field_name}]", 
                   :id => "#{var_name}_#{field_name}_#{markup}", 
                   :type => 'radio', :value => markup}
        if default == markup
          options[:checked] = "checked"
        end

        input(options)
        label markup, :for => "#{var_name}_#{field_name}_#{markup}"
      end
    end
  end

  def current_user
    @current_user ||= state.current_user
  end
  def current_user?(user)
    current_user.try.name == user.name
  end


  def errors_for(record)
    ul.errors do 
      record.errors.each_full do |error| 
        li error
      end
    end if record.errors.any? 
  end 
end

def ContextWiki.create
  ContextWiki::Models.create_schema :assume => 
        (ContextWiki::Models::Page.table_exists? ? 1.0 : 0.0)

  ContextWiki.init if ContextWiki::Models::User.count == 0
end

def ContextWiki.init
  # Create Users
  admins = ContextWiki::Models::Group.new
  admins.id = "admins"
  editors = ContextWiki::Models::Group.new
  editors.id = "editors"

  admin = ContextWiki::Models::User.new(:password => "admin",
                                        :password_confirmation => "admin",
                                        :std_markup => "markdown",
                                        :email => "admin@example.com")
  admin.id = "admin"
  admin.authenticated = true 
  editor = ContextWiki::Models::User.new(:password => "editor",
                                         :password_confirmation => "editor",
                                         :std_markup => "markdown",
                                         :email => "editor@example.com")
  editor.id = "editor"
  editor.authenticated = true 
  user = ContextWiki::Models::User.new(:password => "user",
                                       :password_confirmation => "user",
                                       :std_markup => "markdown",
                                       :email => "user@example.com")
  user.id = "user"
  user.authenticated = true 

  admins.save
  editors.save

  admin.save
  editor.save
  user.save

  admin.groups << admins
  admin.groups << editors
  editor.groups << editors

  index = ContextWiki::Models::Page.new(:name => "index",
                                        :content => "Welcome to ContextWiki",
                                        :markup => "markdown",
                                        :user => admin)
  index.save
end


%w{helper acl random format}.each { |layer|
    load("layer/#{layer}.rb")}

RMQLEvaluator.send(:include, ContextWiki::Models)

if __FILE__ == $0
  ContextWiki::Models::Base.establish_connection :adapter => 'mysql', 
                            :database => 'camping',
                            :username => 'root',
                            :password => ''
  if true 
    gem 'mongrel', "!= 1.1.3"
    require 'mongrel'
    require 'mongrel/camping'

  #  ContextWiki::Models::Base.logger = Logger.new('camping.log')
  #  ContextWiki::Models::Base.logger.level = Logger::WARN 

    ContextWiki.create if ContextWiki.respond_to? :create

    server = Mongrel::Camping::start("0.0.0.0", 3301, "/", ContextWiki)
    puts "** ContextWiki is running on Mongrel at http://localhost:3301/"
    server.run.join
  else
    require 'rack'

    app = Rack::Adapter::Camping.new(ContextWiki)
    puts "** ContextWiki is running on Rack/Mongrel at http://localhost:3301/"
    Rack::Handler::Mongrel.run app, :Port => 3301
  end
else
  # enable logging
  module ContextCamping
    include ContextLogging
  end
  puts "****************************** File wad reloaded ******************************"
end
