class ResourcesController < InheritedResources::Base
  
  actions :index, :show, :new, :create, :edit, :update, :destroy
  respond_to :html, :xml, :json
  
  # GET /resources/custom_action
  def custom_action
  end
  
  protected
    
    def collection
      paginate_options ||= {}
      paginate_options[:page] ||= (params[:page] || 1)
      paginate_options[:per_page] ||= (params[:per_page] || 20)
      @collection = @resources ||= end_of_association_chain.paginate(paginate_options)
    end
    
    def resource
      @resource = @resource ||= end_of_association_chain.find(params[:id])
    end
    
end
