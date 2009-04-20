class ResourcesController < InheritedResources::Base
  
  actions :index, :show, :new, :create, :edit, :update, :destroy
  respond_to :html, :xml, :json
  
  protected
    
    def collection
      paginate_options ||= {}
      paginate_options[:page] ||= (params[:page] || 1)
      paginate_options[:per_page] ||= (params[:per_page] || 20)
      @projects ||= end_of_association_chain.paginate(paginate_options)
    end
    
    def resource
      @project ||= end_of_association_chain.find(params[:id])
    end
    
end
