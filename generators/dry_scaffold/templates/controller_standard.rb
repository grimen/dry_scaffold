class <%= controller_class_name %>Controller < ApplicationController
  
  before_filter :load_resource, :except => [:index, :new, :create]
  before_filter :load_and_paginate_resources, :only => [:index]
  
  # GET /<%= controller_file_name.pluralize %>
  # GET /<%= controller_file_name.pluralize %>.xml
  # GET /<%= controller_file_name.pluralize %>.json
  def indexw
    @<%= controller_file_name.pluralize %> = <%= controller_class_name %>.all
    
    respond_to do |format|
      format.html # index.html.haml
      #format.js  # index.js.rjs
      format.xml  { render :xml => @<%= controller_file_name.pluralize %> }
      format.json { render :json => @<%= controller_file_name.pluralize %> }
    end
  end
  
  # GET /<%= controller_file_name.pluralize %>/1
  # GET /<%= controller_file_name.pluralize %>/1.xml
  # GET /<%= controller_file_name.pluralize %>/1.json
  def show
    respond_to do |format|
      format.html # show.html.haml
      #format.js  # show.js.rjs
      format.xml  { render :xml => @<%= controller_file_name.singularize %> }
      format.json { render :json => @<%= controller_file_name.singularize %> }
    end
  end
  
  # GET /<%= controller_file_name.pluralize %>/new
  # GET /<%= controller_file_name.pluralize %>/new.xml
  # GET /<%= controller_file_name.pluralize %>/new.json
  def new
    @<%= controller_file_name.singularize %> = <%= controller_class_name %>.new
    
    respond_to do |format|
      format.html # new.html.haml
      #format.js  # new.js.rjs
      format.xml  { render :xml => @<%= controller_file_name.singularize %> }
      format.json { render :json => @<%= controller_file_name.singularize %> }
    end
  end
  
  # GET /<%= controller_file_name.pluralize %>/1/edit
  def edit
  end
  
  # POST /<%= controller_file_name.pluralize %>
  # POST /<%= controller_file_name.pluralize %>.xml
  # POST /<%= controller_file_name.pluralize %>.json
  def create
    @<%= controller_file_name.singularize %> = <%= controller_class_name %>.new(params[:<%= controller_file_name.singularize %>])
    
    respond_to do |format|
      if @<%= controller_file_name.singularize %>.save
        flash[:notice] = '<%= controller_file_name.singularize.humanize %> was successfully created.'
        format.html { redirect_to(@<%= controller_file_name.singularize %>) }
        #format.js  # create.js.rjs
        format.xml  { render :xml => @<%= controller_file_name.singularize %>, :status => :created, :location => @<%= controller_file_name.singularize %> }
        format.json { render :json => @<%= controller_file_name.singularize %>, :status => :created, :location => @<%= controller_file_name.singularize %> }
      else
        #flash[:error] = '<%= controller_file_name.singularize.humanize %> could not be created.'
        format.html { render 'new' }
        #format.js  # create.js.rjs
        format.xml  { render :xml => @<%= controller_file_name.singularize %>.errors, :status => :unprocessable_entity }
        format.json { render :json => @<%= controller_file_name.singularize %>.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /<%= controller_file_name.pluralize %>/1
  # PUT /<%= controller_file_name.pluralize %>/1.xml
  # PUT /<%= controller_file_name.pluralize %>/1.json
  def update
    respond_to do |format|
      if @<%= controller_file_name.singularize %>.update_attributes(params[:<%= controller_file_name.singularize %>])
        flash[:notice] = '<%= controller_file_name.singularize.humanize %> was successfully updated.'
        format.html { redirect_to(@<%= controller_file_name.singularize %>) }
        #format.js  # update.js.rjs
        format.xml  { head :ok }
        format.json { head :ok }
      else
        #flash[:error] = '<%= controller_file_name.singularize.humanize %> could not be updated.'
        format.html { render 'edit' }
        #format.js  # update.js.rjs
        format.xml  { render :xml => @<%= controller_file_name.singularize %>.errors, :status => :unprocessable_entity }
        format.json { render :json => @<%= controller_file_name.singularize %>.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /<%= controller_file_name.pluralize %>/1
  # DELETE /<%= controller_file_name.pluralize %>/1.xml
  # DELETE /<%= controller_file_name.pluralize %>/1.json
  def destroy
    respond_to do |format|
      if @<%= controller_file_name.singularize %>.destroy
        flash[:notice] = '<%= controller_file_name.singularize.humanize %> was successfully destroyed.'
        format.html { redirect_to(resources_url) }
        #format.js  # destroy.js.rjs
        format.xml  { head :ok }
        format.json { head :ok }
      else
        flash[:error] = '<%= controller_file_name.singularize.humanize %> could not be destroyed.'
        format.html { redirect_to(resource_url(@<%= controller_file_name.singularize %>)) }
        #format.js  # destroy.js.rjs
        format.xml  { head :unprocessable_entity }
        format.json { head :unprocessable_entity }
      end
    end
  end
  
  protected
    
    def collection
      paginate_options ||= {}
      paginate_options[:page] ||= (params[:page] || 1)
      paginate_options[:per_page] ||= (params[:per_page] || 20)
      @<%= controller_file_name.pluralize %> ||= end_of_association_chain.paginate(paginate_options)
    end
    alias :load_and_paginate_resources :collection
    
    def resource
      @<%= controller_file_name.singularize %> ||= end_of_association_chain.find(params[:id])
    end
    alias :load_resource :resource
    
end