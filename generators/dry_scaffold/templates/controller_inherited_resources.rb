class <%= controller_class_name %>Controller < InheritedResources::Base
  
<% if actions -%>
  actions <%= symbol_array_to_expression(actions) %>
<% end -%>
<% if formats -%>
  respond_to <%= symbol_array_to_expression(formats) %>
<% end -%>
  
<% (actions - DryScaffoldGenerator::DEFAULT_CONTROLLER_ACTIONS).each do |action| -%>
  # GET /<%= plural_name %>/<%= action.to_s %>
  def <%= action.to_s %>
  end
  
<% end -%>
  protected
    
    def collection
      paginate_options ||= {}
      paginate_options[:page] ||= (params[:page] || 1)
      paginate_options[:per_page] ||= (params[:per_page] || 20)
      @collection = @<%= plural_name %> ||= end_of_association_chain.paginate(paginate_options)
    end
    
    def resource
      @resource = @<%= singular_name %> ||= end_of_association_chain.find(params[:id])
    end
    
end