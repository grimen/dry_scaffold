class ResourcesController < ApplicationController
  
  before_filter :load_resource, :only => [:show, :edit, :update, :destroy]
  before_filter :load_and_paginate_resources, :only => [:index]
  
  # GET /resources
  # GET /resources.xml
  # GET /resources.json
  def index
    respond_to do |format|
      format.html # index.html.haml
      #format.js  # index.js.rjs
      format.xml  { render :xml => @resources }
      format.json { render :json => @resources }
      format.atom # index.atom.builder
      format.rss  # index.rss.builder
    end
  end
  
  # GET /resources/:id
  # GET /resources/:id.xml
  # GET /resources/:id.json
  def show
    respond_to do |format|
      format.html # show.html.haml
      #format.js  # show.js.rjs
      format.xml  { render :xml => @resource }
      format.json { render :json => @resource }
    end
  end
  
  # GET /resources/new
  # GET /resources/new.xml
  # GET /resources/new.json
  def new
    @resource = Resource.new
    
    respond_to do |format|
      format.html # new.html.haml
      #format.js  # new.js.rjs
      format.xml  { render :xml => @resource }
      format.json { render :json => @resource }
    end
  end
  
  # GET /resources/:id/edit
  def edit
  end
  
  # POST /resources
  # POST /resources.xml
  # POST /resources.json
  def create
    @resource = Resource.new(params[:resource])
    
    respond_to do |format|
      if @resource.save
        flash[:notice] = 'Resource was successfully created.'
        format.html { redirect_to(@resource) }
        #format.js  # create.js.rjs
        format.xml  { render :xml => @resource, :status => :created, :location => @resource }
        format.json { render :json => @resource, :status => :created, :location => @resource }
      else
        #flash[:error] = 'Resource could not be created.'
        format.html { render 'new' }
        #format.js  # create.js.rjs
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
        format.json { render :json => @resource.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /resources/:id
  # PUT /resources/:id.xml
  # PUT /resources/:id.json
  def update
    respond_to do |format|
      if @resource.update_attributes(params[:resource])
        flash[:notice] = 'Resource was successfully updated.'
        format.html { redirect_to(@resource) }
        #format.js  # update.js.rjs
        format.xml  { head :ok }
        format.json { head :ok }
      else
        #flash[:error] = 'Resource could not be updated.'
        format.html { render 'edit' }
        #format.js  # update.js.rjs
        format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
        format.json { render :json => @resource.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /resources/:id
  # DELETE /resources/:id.xml
  # DELETE /resources/:id.json
  def destroy
    respond_to do |format|
      if @resource.destroy
        flash[:notice] = 'Resource was successfully destroyed.'
        format.html { redirect_to(resources_url) }
        #format.js  # destroy.js.rjs
        format.xml  { head :ok }
        format.json { head :ok }
      else
        flash[:error] = 'Resource could not be destroyed.'
        format.html { redirect_to(resource_url(@resource)) }
        #format.js  # destroy.js.rjs
        format.xml  { head :unprocessable_entity }
        format.json { head :unprocessable_entity }
      end
    end
  end
  
  # GET /resources/custom_action
  def custom_action
  end
  
  protected
    
    def collection
      paginate_options ||= {}
      paginate_options[:page] ||= (params[:page] || 1)
      paginate_options[:per_page] ||= (params[:per_page] || 20)
      @collection = @resources ||= Resource.paginate(paginate_options)
    end
    alias :load_and_paginate_resources :collection
    
    def resource
      @resource = @resource = ||= Resource.find(params[:id])
    end
    alias :load_resource :resource
    
end
