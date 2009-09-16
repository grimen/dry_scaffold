require File.dirname(__FILE__) + '/../spec_helper'
 
describe <%= controller_class_name %>Controller do
<% if options[:fixtures] -%>
  fixtures :all
<% end -%>
  integrate_views
<% unless options[:factory_framework]==:fixtures %>
  before(:each) do
    <%= build_object %>
  end
<% end %>
<% if actions.include?(:index) -%>
  it "index action should render index template" do
    get :index
    response.should render_template(:index)
  end
  
<% end %>
<% if actions.include?(:show) -%>
  it "show action should render show template" do
    get :show, :id => <%= class_name %>.first
    response.should render_template(:show)
  end
  
<% end %>
<% if actions.include?(:new) -%>
  it "new action should render new template" do
    get :new
    response.should render_template(:new)
  end
  
<% end %>
<% if actions.include?(:create) -%>
  it "create action should render new template when model is invalid" do
    <%= class_name %>.any_instance.stubs(:valid?).returns(false)
    post :create
    response.should render_template(:new)
  end
  
  it "create action should redirect when model is valid" do
    <%= class_name %>.any_instance.stubs(:valid?).returns(true)
    post :create
    response.should redirect_to(<%= singular_name %>_url(assigns[:<%= singular_name %>]))
  end

<% end %>
<% if actions.include?(:edit) -%>
  it "edit action should render edit template" do
    get :edit, :id => <%= class_name %>.first
    response.should render_template(:edit)
  end
  
<% end %>
<% if actions.include?(:update) -%>  
  it "update action should render edit template when model is invalid" do
    <%= class_name %>.any_instance.stubs(:valid?).returns(false)
    put :update, :id => <%= class_name %>.first
    response.should render_template(:edit)
  end

  it "update action should redirect when model is valid" do
    <%= class_name %>.any_instance.stubs(:valid?).returns(true)
    put :update, :id => <%= class_name %>.first
    response.should redirect_to(<%= singular_name %>_url(assigns[:<%= singular_name %>]))
  end
  
<% end %>
<% if actions.include?(:destroy) -%>
  it "destroy action should destroy model and redirect to index action" do
    <%= singular_name %> = <%= class_name %>.first
    delete :destroy, :id => <%= singular_name %>
    response.should redirect_to(<%= plural_name %>_url)
    <%= class_name %>.exists?(<%= singular_name %>.id).should be_false
  end
  
<% end %>
<% (actions - DryScaffoldGenerator::DEFAULT_CONTROLLER_ACTIONS).each do |action| -%>
  it '<%= action.to_s %> action should render <%= action.to_s %> template' do
    get :<%= action.to_s %>
    response.should render_template(:<%= action.to_s %>)
  end
  
<% end -%>
end
