require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  
<% if actions.include?(:create) -%>
  test 'create' do
    <%= class_name %>.any_instance.expects(:save).returns(true)
    <%= resource_instance %> = <%= build_object %>
    post :create, :<%= singular_name %> => <%= resource_instance %>.attributes
    assert_response :redirect
  end
  
  test 'create with failure' do
    <%= class_name %>.any_instance.expects(:save).returns(false)
    <%= resource_instance %> = <%= build_object %>
    post :create, :<%= singular_name %> => <%= resource_instance %>.attributes
    assert_template 'new'
  end
  
<% end -%>
<% if actions.include?(:update) -%>
  test 'update' do
    <%= class_name %>.any_instance.expects(:save).returns(true)
    <%= resource_instance %> = <%= build_object %>
    put :update, :id => <%= build_object %>.to_param, :<%= singular_name %> => <%= resource_instance %>.attributes
    assert_response :redirect
  end
  
  test 'update with failure' do
    <%= class_name %>.any_instance.expects(:save).returns(false)
    <%= resource_instance %> = <%= build_object %>
    put :update, :id => <%= build_object %>.to_param, :<%= singular_name %> => <%= resource_instance %>.attributes
    assert_template 'edit'
  end
  
<% end -%>
<% if actions.include?(:destroy) -%>
  test 'destroy' do
    <%= class_name %>.any_instance.expects(:destroy).returns(true)
    <%= resource_instance %> = <%= build_object %>
    delete :destroy, :id => <%= resource_instance %>.to_param
    assert_not_nil flash[:notice] 
    assert_response :redirect
  end
  
  # Not possible: destroy with failure
  
<% end -%>
<% if actions.include?(:new) -%>
  test 'new' do
    get :new
    assert_response :success
  end
  
<% end -%>
<% if actions.include?(:edit) -%>
  test 'edit' do
    <%= resource_instance %> = <%= build_object %>
    get :edit, :id => <%= resource_instance %>.to_param
    assert_response :success
  end
  
<% end -%>
<% if actions.include?(:show) -%>
  test 'show' do
    <%= resource_instance %> = <%= build_object %>
    get :show, :id => <%= resource_instance %>.to_param
    assert_response :success
  end
  
<% end -%>
<% if actions.include?(:index) -%>
  test 'index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:<%= table_name %>)
  end
  
<% end -%>
<% (actions - DryScaffoldGenerator::DEFAULT_CONTROLLER_ACTIONS).each do |action| -%>
  test '<%= action.to_s %>' do
    get :<%= action.to_s %>
    assert_response :success
  end
  
<% end -%>
end