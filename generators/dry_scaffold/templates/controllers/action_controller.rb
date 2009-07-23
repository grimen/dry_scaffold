class <%= controller_class_name %>Controller < ApplicationController
  
<% if actions -%>
  before_filter :load_resource, :only => [<%= symbol_array_to_expression(actions & DryScaffoldGenerator::DEFAULT_MEMBER_AUTOLOAD_ACTIONS) %>]
<% end -%>
<% if actions -%>
  before_filter :load_and_paginate_resources, :only => [<%= symbol_array_to_expression(actions & DryScaffoldGenerator::DEFAULT_COLLECTION_AUTOLOAD_ACTIONS) %>]
  
<% end -%>
<% if actions.include?(:index) -%>
<% formats.each do |_format| -%>
  # GET /<%= plural_name %><%= ".#{_format}" unless _format == :html %>
<% end -%>
  def index
    respond_to do |format|
<% formats.each do |_format| -%>
<% case _format when :html then -%>
      format.html # index.html.haml
<% when :js then -%>
      format.js   # index.js.rjs
<% when :xml, :json then -%>
      format.<%= _format %>  { render :<%= _format %> => @<%= plural_name %> }
<% when :yml, :yaml then -%>
      format.yaml { render :text => @<%= plural_name %>.to_yaml, :content_type => :'text/yaml' }
<% when :txt, :text then -%>
      format.txt  { render :text => @<%= plural_name %>.to_s, :content_type => :text }
<% when :atom, :rss then -%>
<% unless options[:skip_builders] -%>
      format.<%= _format %> # index.<%= _format %>.builder
<% else -%>
      format.<%= _format %> { }
<% end -%>
<% else -%>
      format.<%= _format %>  { }
<% end -%>
<% end -%>
    end
  end
  
<% end -%>
<% if actions.include?(:show) -%>
<% formats.each do |_format| -%>
  # GET /<%= plural_name %>/:id<%= ".#{_format}" unless _format == :html %>
<% end -%>
  def show
    respond_to do |format|
<% formats.each do |_format| -%>
<% case _format when :html then -%>
      format.html # show.html.haml
<% when :js then -%>
      format.js   # show.js.rjs
<% when :xml, :json then -%>
      format.<%= _format %>  { render :<%= _format %> => @<%= plural_name %> }
<% when :yml, :yaml then -%>
      format.yaml { render :text => @<%= plural_name %>.to_yaml, :content_type => :'text/yaml' }
<% when :txt, :text then -%>
      format.txt  { render :text => @<%= plural_name %>.to_s, :content_type => :text }
<% else -%>
      format.<%= _format %>  { }
<% end -%>
<% end -%>
    end
  end
  
<% end -%>
<% if actions.include?(:new) -%>
<% formats.each do |_format| -%>
  # GET /<%= plural_name %>/new<%= ".#{_format}" unless _format == :html %>
<% end -%>
  def new
    <%= resource_instance %> = <%= class_name %>.new
    
    respond_to do |format|
<% formats.each do |_format| -%>
<% case _format when :html then -%>
      format.html # new.html.haml
<% when :js then -%>
      format.js   # new.js.rjs
<% when :xml, :json then -%>
      format.<%= _format %>  { render :<%= _format %> => <%= resource_instance %> }
<% when :yml, :yaml then -%>
      format.yaml { render :text => <%= resource_instance %>.to_yaml, :content_type => :'text/yaml' }
<% when :txt, :text then -%>
      format.txt  { render :text => <%= resource_instance %>.to_s, :content_type => :text }
<% else -%>
      format.<%= _format %>  { }
<% end -%>
<% end -%>
    end
  end
  
<% end -%>
<% if actions.include?(:edit) -%>
  # GET /<%= plural_name %>/:id/edit
  def edit
  end
  
<% end -%>
<% if actions.include?(:create) -%>
<% formats.each do |_format| -%>
  # POST /<%= plural_name %><%= ".#{_format}" unless _format == :html %>
<% end -%>
  def create
    <%= resource_instance %> = <%= class_name %>.new(params[:<%= singular_name %>])
    
    respond_to do |format|
      if <%= resource_instance %>.save
        flash[:notice] = "<%= singular_name.humanize %> was successfully created."
<% formats.each do |_format| -%>
<% case _format when :html then -%>
        format.html { redirect_to(<%= resource_instance %>) }
<% when :js then -%>
        format.js   # create.js.rjs
<% when :xml, :json then -%>
        format.<%= _format %>  { render :<%= _format %> => <%= resource_instance %>, :status => :created, :location => <%= resource_instance %> }
<% when :yml, :yaml then -%>
      format.yaml { render :text => <%= resource_instance %>.to_yaml, :content_type => :'text/yaml', :status => :created, :location => <%= resource_instance %> }
<% when :txt, :text then -%>
        format.txt  { render :text => <%= resource_instance %>.to_s, :content_type => :text, :status => :created, :location => <%= resource_instance %> }
<% else -%>
        format.<%= _format %>  { }
<% end -%>
<% end -%>
      else
        flash[:error] = "<%= singular_name.humanize %> could not be created."
<% formats.each do |_format| -%>
<% case _format when :html then -%>
        format.html { render 'new' }
<% when :js then -%>
        format.js   # create.js.rjs
<% when :xml, :json then -%>
        format.<%= _format %>  { render :<%= _format %> => <%= resource_instance %>.errors, :status => :unprocessable_entity }
<% when :yml, :yaml then -%>
      format.yaml { render :text => <%= resource_instance %>.errors.to_yaml, :content_type => :'text/yaml', :status => :unprocessable_entity }
<% when :txt, :text then -%>
        format.txt  { render :text => <%= resource_instance %>.errors.to_s, :content_type => :text, :status => :unprocessable_entity }
<% else -%>
        format.<%= _format %>  { }
<% end -%>
<% end -%>
      end
    end
  end
  
<% end -%>
<% if actions.include?(:update) -%>
<% formats.each do |_format| -%>
  # PUT /<%= plural_name %>/:id<%= ".#{_format}" unless _format == :html %>
<% end -%>
  def update
    respond_to do |format|
      if <%= resource_instance %>.update_attributes(params[:<%= singular_name %>])
        flash[:notice] = "<%= singular_name.humanize %> was successfully updated."
<% formats.each do |_format| -%>
<% case _format when :html then -%>
        format.html { redirect_to(<%= resource_instance %>) }
<% when :js then -%>
        format.js   # update.js.rjs
<% when :xml, :json, :yml, :yaml, :txt, :text then -%>
        format.<%= _format %>  { head :ok }
<% else -%>
        format.<%= _format %>  { head :ok }
<% end -%>
<% end -%>
      else
        flash[:error] = "<%= singular_name.humanize %> could not be updated."
<% formats.each do |_format| -%>
<% case _format when :html then -%>
        format.html { render 'edit' }
<% when :js then -%>
        format.js   # update.js.rjs
<% when :xml, :json then -%>
        format.<%= _format %>  { render :<%= _format %> => <%= resource_instance %>.errors, :status => :unprocessable_entity }
<% when :yml, :yaml then -%>
        format.yaml { render :text => <%= resource_instance %>.errors.to_yaml, :status => :unprocessable_entity }
<% when :txt, :text then -%>
        format.txt  { render :text => <%= resource_instance %>.errors.to_s, :status => :unprocessable_entity }
<% else -%>
        format.<%= _format %>  { head :unprocessable_entity }
<% end -%>
<% end -%>
      end
    end
  end
  
<% end -%>
<% if actions.include?(:destroy) -%>
<% formats.each do |_format| -%>
  # DELETE /<%= plural_name %>/:id<%= ".#{_format}" unless _format == :html %>
<% end -%>
  def destroy
    respond_to do |format|
      if <%= resource_instance %>.destroy
        flash[:notice] = "<%= singular_name.humanize %> was successfully destroyed."
<% formats.each do |_format| -%>
<% case _format when :html then -%>
        format.html { redirect_to(<%= plural_name %>_url) }
<% when :js then -%>
        format.js   # destroy.js.rjs
<% when :xml, :json, :yml, :yaml, :txt, :text then -%>
        format.<%= _format %>  { head :ok }
<% else -%>
        format.<%= _format %>  { head :ok }
<% end -%>
<% end -%>
      else
        flash[:error] = "<%= singular_name.humanize %> could not be destroyed."
<% formats.each do |_format| -%>
<% case _format when :html then -%>
        format.html { redirect_to(<%= singular_name %>_url(<%= resource_instance %>)) }
<% when :js then -%>
        format.js   # destroy.js.rjs
<% when :xml, :json, :yml, :yaml, :txt, :text then -%>
        format.<%= _format %>  { head :unprocessable_entity }
<% else -%>
        format.<%= _format %>  { head :unprocessable_entity }
<% end -%>
<% end -%>
      end
    end
  end
  
<% end -%>
<% (actions - DryScaffoldGenerator::DEFAULT_CONTROLLER_ACTIONS).each do |action| -%>
  # GET /<%= plural_name %>/<%= action.to_s %>
  def <%= action.to_s %>
    
  end
  
<% end -%>
  protected
    
    def collection
<% if options[:pagination] -%>
      paginate_options ||= {}
      paginate_options[:page] ||= (params[:page] || 1)
      paginate_options[:per_page] ||= (params[:per_page] || 20)
      @collection = @<%= plural_name %> ||= <%= class_name %>.paginate(paginate_options)
<% else -%>
      @collection = @<%= plural_name %> ||= <%= class_name %>.all
<% end -%>
    end
    alias :load_and_paginate_resources :collection
    
    def resource
      @resource = <%= resource_instance %> ||= <%= class_name %>.find(params[:id])
    end
    alias :load_resource :resource
    
end