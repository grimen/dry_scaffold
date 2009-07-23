class <%= controller_class_name %>Controller < InheritedResources::Base
  
<% if actions -%>
  actions <%= symbol_array_to_expression(actions) %>
<% end -%>
<% if formats -%>
  respond_to <%= symbol_array_to_expression(formats) %>
  
<% end -%>
<% if actions -%>
  before_filter :load_resource, :only => [<%= symbol_array_to_expression(actions & DryScaffoldGenerator::DEFAULT_MEMBER_AUTOLOAD_ACTIONS) %>]
<% end -%>
<% if actions -%>
  before_filter :load_and_paginate_resources, :only => [<%= symbol_array_to_expression(actions & DryScaffoldGenerator::DEFAULT_COLLECTION_AUTOLOAD_ACTIONS) %>]
  
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
      @collection = @<%= model_plural_name %> ||= end_of_association_chain.paginate(paginate_options)
<% else -%>
      @collection = @<%= model_plural_name %> ||= end_of_association_chain.all
<% end -%>
    end
    alias :load_and_paginate_resources :collection
    
    def resource
      @resource = @<%= model_singular_name %> ||= end_of_association_chain.find(params[:id])
    end
    alias :load_resource :resource
    
end