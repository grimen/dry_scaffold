class DucksController < InheritedResources::Base
  
  actions :index, :show, :new, :create, :edit, :update, :destroy
  respond_to :html, :xml, :json
  respond_to :atom, :rss, :only => [:index]
  
  # GET /ducks/custom_action
  def custom_action
    
  end
  
  protected
    
    def collection
      paginate_options ||= {}
      paginate_options[:page] ||= (params[:page] || 1)
      paginate_options[:per_page] ||= (params[:per_page] || 20)
      @collection = @ducks ||= end_of_association_chain.paginate(paginate_options)
    end
    
    def resource
      @resource = @duck ||= end_of_association_chain.find(params[:id])
    end
    
end
