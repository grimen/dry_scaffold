require 'test_helper'

class ResourceControllerTest < ActionController::TestCase
  
  def test_create
    Resource.any_instance.expects(:save).returns(true)
    post :create, :resource => { }
    assert_response :redirect
  end
  
  def test_create_with_failure
    Resource.any_instance.expects(:save).returns(false)
    post :create, :resource => { }
    assert_template 'new'
  end
  
  def test_destroy
    Resource.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => resources(:one).to_param
    assert_not_nil flash[:notice]
    assert_response :redirect
  end
  
  def test_destroy_with_failure
    Resource.any_instance.expects(:destroy).returns(false)
    delete :destroy, :id => resources(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end
  
  def test_edit
    get :edit, :id => resources(:one).to_param
    assert_response :success
  end
  
  def test_index
    get :index
    assert_response :success
    assert_not_nil assigns(:resources)
  end
  
  def test_new
    get :new
    assert_response :success
  end
  
  def test_show
    get :show, :id => resources(:one).to_param
    assert_response :success
  end
  
  def test_update
    Resource.any_instance.expects(:save).returns(true)
    put :update, :id => resources(:one).to_param, :resource => { }
    assert_response :redirect
  end
  
  def test_update_with_failure
    Resource.any_instance.expects(:save).returns(false)
    put :update, :id => resources(:one).to_param, :resource => { }
    assert_template 'edit'
  end
  
end