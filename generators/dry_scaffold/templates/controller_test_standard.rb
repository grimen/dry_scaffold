require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  
  test "create" do
    <%= class_name %>.any_instance.expects(:save).returns(true)
    post :create, :<%= file_name %> => { }
    assert_response :redirect
  end
  
  test "create_with_failure" do
    <%= class_name %>.any_instance.expects(:save).returns(false)
    post :create, :<%= file_name %> => { }
    assert_template 'new'
  end
  
  test "destroy" do
    <%= class_name %>.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => <%= table_name %>(:one).to_param
    assert_not_nil flash[:notice]
    assert_response :redirect
  end
  
  test "destroy_with_failure" do
    <%= class_name %>.any_instance.expects(:destroy).returns(false)
    delete :destroy, :id => <%= table_name %>(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end
  
  test "edit" do
    get :edit, :id => <%= table_name %>(:one).to_param
    assert_response :success
  end
  
  test "index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:<%= table_name %>)
  end
  
  test "new" do
    get :new
    assert_response :success
  end
  
  test "show" do
    get :show, :id => <%= table_name %>(:one).to_param
    assert_response :success
  end
  
  test "update" do
    <%= class_name %>.any_instance.expects(:save).returns(true)
    put :update, :id => <%= table_name %>(:one).to_param, :<%= file_name %> => { }
    assert_response :redirect
  end
  
  test "update_with_failure" do
    <%= class_name %>.any_instance.expects(:save).returns(false)
    put :update, :id => <%= table_name %>(:one).to_param, :<%= file_name %> => { }
    assert_template 'edit'
  end
  
end