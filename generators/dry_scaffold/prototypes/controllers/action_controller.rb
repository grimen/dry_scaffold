class DucksController < ApplicationController
  
  before_filter :load_resource, :only => [:show, :edit, :update, :destroy]
  before_filter :load_and_paginate_resource, :only => [:index]
  
  # GET /ducks
  # GET /ducks.xml
  # GET /ducks.json
  def index
    respond_to do |format|
      format.html # index.html.haml
      #format.js  # index.js.rjs
      format.xml  { render :xml => @ducks }
      format.json { render :json => @ducks }
      format.atom # index.atom.builder
      format.rss  # index.rss.builder
    end
  end
  
  # GET /ducks/:id
  # GET /ducks/:id.xml
  # GET /ducks/:id.json
  def show
    respond_to do |format|
      format.html # show.html.haml
      #format.js  # show.js.rjs
      format.xml  { render :xml => @duck }
      format.json { render :json => @duck }
    end
  end
  
  # GET /ducks/new
  # GET /ducks/new.xml
  # GET /ducks/new.json
  def new
    @duck = Duck.new
    
    respond_to do |format|
      format.html # new.html.haml
      #format.js  # new.js.rjs
      format.xml  { render :xml => @duck }
      format.json { render :json => @duck }
    end
  end
  
  # GET /ducks/:id/edit
  def edit
  end
  
  # POST /ducks
  # POST /ducks.xml
  # POST /ducks.json
  def create
    @duck = Duck.new(params[:duck])
    
    respond_to do |format|
      if @duck.save
        flash[:notice] = "Duck was successfully created."
        format.html { redirect_to(@duck) }
        #format.js  # create.js.rjs
        format.xml  { render :xml => @duck, :status => :created, :location => @duck }
        format.json { render :json => @duck, :status => :created, :location => @duck }
      else
        flash[:error] = "Duck could not be created."
        format.html { render 'new' }
        #format.js  # create.js.rjs
        format.xml  { render :xml => @duck.errors, :status => :unprocessable_entity }
        format.json { render :json => @duck.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /ducks/:id
  # PUT /ducks/:id.xml
  # PUT /ducks/:id.json
  def update
    respond_to do |format|
      if @duck.update_attributes(params[:duck])
        flash[:notice] = "Duck was successfully updated."
        format.html { redirect_to(@duck) }
        #format.js  # update.js.rjs
        format.xml  { head :ok }
        format.json { head :ok }
      else
        flash[:error] = "Duck could not be updated."
        format.html { render 'edit' }
        #format.js  # update.js.rjs
        format.xml  { render :xml => @duck.errors, :status => :unprocessable_entity }
        format.json { render :json => @duck.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /ducks/:id
  # DELETE /ducks/:id.xml
  # DELETE /ducks/:id.json
  def destroy
    respond_to do |format|
      if @duck.destroy
        flash[:notice] = "Duck was successfully destroyed."
        format.html { redirect_to(ducks_url) }
        #format.js  # destroy.js.rjs
        format.xml  { head :ok }
        format.json { head :ok }
      else
        flash[:error] = "Duck could not be destroyed."
        format.html { redirect_to(duck_url(@duck)) }
        #format.js  # destroy.js.rjs
        format.xml  { head :unprocessable_entity }
        format.json { head :unprocessable_entity }
      end
    end
  end
  
  # GET /ducks/custom_action
  def custom_action
    
  end
  
  protected
    
    def collection
      paginate_options ||= {}
      paginate_options[:page] ||= (params[:page] || 1)
      paginate_options[:per_page] ||= (params[:per_page] || 20)
      @collection = @ducks ||= Duck.paginate(paginate_options)
    end
    alias :load_and_paginate_ducks :collection
    
    def resource
      @resource = @duck = ||= Duck.find(params[:id])
    end
    alias :load_resource :resource
    
end
