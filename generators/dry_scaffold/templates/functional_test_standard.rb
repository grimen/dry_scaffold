require 'test_helper'

class <%= controller_class_name %>ControllerTest < ActionController::TestCase
  
  def test_create
    <%= class_name %>.any_instance.expects(:save).returns(true)
    post :create, :<%= file_name %> => { }
    assert_response :redirect
  end
  
  def test_create_with_failure
    <%= class_name %>.any_instance.expects(:save).returns(false)
    post :create, :<%= file_name %> => { }
    assert_template 'new'
  end
  
  def test_destroy
    <%= class_name %>.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => <%= table_name %>(:one).to_param
    assert_not_nil flash[:notice]
    assert_response :redirect
  end
  
  def test_destroy_with_failure
    <%= class_name %>.any_instance.expects(:destroy).returns(false)
    delete :destroy, :id => <%= table_name %>(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end
  
  def test_edit
    get :edit, :id => <%= table_name %>(:one).to_param
    assert_response :success
  end
  
  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:<%= table_name %>)
  end
  
  def test_new
    get :new
    assert_response :success
  end
  
  def test_show
    get :show, :id => <%= table_name %>(:one).to_param
    assert_response :success
  end
  
  def test_update
    <%= class_name %>.any_instance.expects(:save).returns(true)
    put :update, :id => <%= table_name %>(:one).to_param, :<%= file_name %> => { }
    assert_response :redirect
  end
  
  def test_update_with_failure
    <%= class_name %>.any_instance.expects(:save).returns(false)
    put :update, :id => <%= table_name %>(:one).to_param, :<%= file_name %> => { }
    assert_template 'edit'
  end
  
end