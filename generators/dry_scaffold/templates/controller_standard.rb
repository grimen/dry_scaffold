class <%= controller_class_name %>Controller < ApplicationController
  
  before_filter :load_resource, :except => [:index, :new, :create]
  before_filter :load_and_paginate_resources, :only => [:index]
  
  # GET /<%= plural_name %>
  # GET /<%= plural_name %>.xml
  # GET /<%= plural_name %>.json
  def index
    @<%= plural_name %> = <%= class_name %>.all
    
    respond_to do |format|
      format.html # index.html.haml
      #format.js  # index.js.rjs
      format.xml  { render :xml => @<%= plural_name %> }
      format.json { render :json => @<%= plural_name %> }
    end
  end
  
  # GET /<%= plural_name %>/1
  # GET /<%= plural_name %>/1.xml
  # GET /<%= plural_name %>/1.json
  def show
    respond_to do |format|
      format.html # show.html.haml
      #format.js  # show.js.rjs
      format.xml  { render :xml => @<%= singular_name %> }
      format.json { render :json => @<%= singular_name %> }
    end
  end
  
  # GET /<%= plural_name %>/new
  # GET /<%= plural_name %>/new.xml
  # GET /<%= plural_name %>/new.json
  def new
    @<%= singular_name %> = <%= class_name %>.new
    
    respond_to do |format|
      format.html # new.html.haml
      #format.js  # new.js.rjs
      format.xml  { render :xml => @<%= singular_name %> }
      format.json { render :json => @<%= singular_name %> }
    end
  end
  
  # GET /<%= plural_name %>/1/edit
  def edit
  end
  
  # POST /<%= plural_name %>
  # POST /<%= plural_name %>.xml
  # POST /<%= plural_name %>.json
  def create
    @<%= singular_name %> = <%= class_name %>.new(params[:<%= singular_name %>])
    
    respond_to do |format|
      if @<%= singular_name %>.save
        flash[:notice] = '<%= singular_name.humanize %> was successfully created.'
        format.html { redirect_to(@<%= singular_name %>) }
        #format.js  # create.js.rjs
        format.xml  { render :xml => @<%= singular_name %>, :status => :created, :location => @<%= singular_name %> }
        format.json { render :json => @<%= singular_name %>, :status => :created, :location => @<%= singular_name %> }
      else
        #flash[:error] = '<%= singular_name.humanize %> could not be created.'
        format.html { render 'new' }
        #format.js  # create.js.rjs
        format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
        format.json { render :json => @<%= singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /<%= plural_name %>/1
  # PUT /<%= plural_name %>/1.xml
  # PUT /<%= plural_name %>/1.json
  def update
    respond_to do |format|
      if @<%= singular_name %>.update_attributes(params[:<%= singular_name %>])
        flash[:notice] = '<%= singular_name.humanize %> was successfully updated.'
        format.html { redirect_to(@<%= singular_name %>) }
        #format.js  # update.js.rjs
        format.xml  { head :ok }
        format.json { head :ok }
      else
        #flash[:error] = '<%= singular_name.humanize %> could not be updated.'
        format.html { render 'edit' }
        #format.js  # update.js.rjs
        format.xml  { render :xml => @<%= singular_name %>.errors, :status => :unprocessable_entity }
        format.json { render :json => @<%= singular_name %>.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /<%= plural_name %>/1
  # DELETE /<%= plural_name %>/1.xml
  # DELETE /<%= plural_name %>/1.json
  def destroy
    respond_to do |format|
      if @<%= singular_name %>.destroy
        flash[:notice] = '<%= singular_name.humanize %> was successfully destroyed.'
        format.html { redirect_to(<%= plural_name %>_url) }
        #format.js  # destroy.js.rjs
        format.xml  { head :ok }
        format.json { head :ok }
      else
        flash[:error] = '<%= singular_name.humanize %> could not be destroyed.'
        format.html { redirect_to(<%= singular_name %>_url(@<%= singular_name %>)) }
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
      @<%= plural_name %> ||= <%= class_name %>.paginate(paginate_options)
    end
    alias :load_and_paginate_resources :collection
    
    def resource
      @<%= singular_name %> ||= <%= class_name %>.find(params[:id])
    end
    alias :load_resource :resource
    
end