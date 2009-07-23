require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  
<% if actions.include?(:create) -%>
  context 'create' do
    setup do
      <%= resource_instance %> = <%= build_object %>
      post :create, :<%= singular_name %> => <%= resource_instance %>.attributes
      <%= resource_instance %> = <%= class_name %>.find(:all).last
    end
    should_redirect_to '<%= show_path %>'
  end
  
<% end -%>
<% if actions.include?(:update) -%>
  context 'update' do
    setup do
      <%= resource_instance %> = <%= build_object %>
      put :update, :id => <%= resource_instance %>.to_param, :<%= singular_name %> => <%= resource_instance %>.attributes
    end
    should_redirect_to '<%= show_path %>'
  end
  
<% end -%>
<% if actions.include?(:destroy) -%>
  context 'destroy' do
    setup do
      <%= resource_instance %> = <%= build_object %>
      delete :destroy, :id => <%= resource_instance %>.to_param
    end
    should_redirect_to '<%= index_path %>'
  end
  
<% end -%>
<% if actions.include?(:new) -%>
  context 'new' do
    setup do
      get :new
    end
    should_respond_with :success
    should_render_template :new
    should_assign_to :<%= singular_name %>
  end
  
<% end -%>
<% if actions.include?(:edit) -%>
  context 'edit' do
    setup do
      <%= resource_instance %> = <%= build_object %>
      get :edit, :id => <%= resource_instance %>.to_param
    end
    should_respond_with :success
    should_render_template :edit
    should_assign_to :<%= singular_name %>
  end
  
<% end -%>
<% if actions.include?(:show) -%>
  context 'show' do
    setup do
      <%= resource_instance %> = <%= build_object %>
      get :show, :id => <%= resource_instance %>.to_param
    end
    should_respond_with :success
    should_render_template :show
    should_assign_to :<%= singular_name %>
  end
  
<% end -%>
<% if actions.include?(:index) -%>
  context 'index' do
    setup do
      get :index
    end
    should_respond_with :success
    should_assign_to :<%= plural_name %>
  end
  
<% end -%>
<% (actions - DryScaffoldGenerator::DEFAULT_CONTROLLER_ACTIONS).each do |action| -%>
  context '<%= action.to_s %>' do
    setup do
      get :<%= action.to_s %>
    end
    should_respond_with :success
  end
  
<% end -%>
end
