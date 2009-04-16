class <%= controller_class_name %>Controller < InheritedResources::Base
  
  actions :index, :show, :new, :create, :edit, :update
  respond_to :html, :xml, :json
  
  protected
    
    def collection
      paginate_options ||= {}
      paginate_options[:page] ||= (params[:page] || 1)
      paginate_options[:per_page] ||= (params[:per_page] || 20)
      @<%= self.controller_file_name.pluralize %> ||= end_of_association_chain.paginate(paginate_options)
    end
    
    def resource
      @<%= self.controller_file_name %> ||= end_of_association_chain.find(params[:id])
    end
    
end