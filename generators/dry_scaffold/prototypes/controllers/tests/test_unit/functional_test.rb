require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

class ResourceControllerTest < ActionController::TestCase
  
  test 'create' do
    Resource.any_instance.expects(:save).returns(true)
    post :create, :resource => { }
    assert_response :redirect 
  end
  
  test 'create_with_failure' do
    Resource.any_instance.expects(:save).returns(false)
    post :create, :resource => { }
    assert_template 'new'
  end
  
  test 'destroy' do
    Resource.any_instance.expects(:destroy).returns(true)
    delete :destroy, :id => resources(:one).to_param
    assert_not_nil flash[:notice]
    assert_response :redirect
  end
  
  test 'destroy_with_failure' do
    Resource.any_instance.expects(:destroy).returns(false)
    delete :destroy, :id => resources(:one).to_param
    assert_not_nil flash[:error]
    assert_response :redirect
  end
  
  test 'edit' do
    get :edit, :id => resources(:one).to_param
    assert_response :success
  end
  
  test 'index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:resources)
  end
  
  test 'new' do
    get :new
    assert_response :success
  end
  
  test 'show' do
    get :show, :id => resources(:one).to_param
    assert_response :success
  end
  
  test 'update' do
    Resource.any_instance.expects(:save).returns(true)
    put :update, :id => resources(:one).to_param, :resource => { }
    assert_response :redirect
  end
  
  test 'update_with_failure' do
    Resource.any_instance.expects(:save).returns(false)
    put :update, :id => resources(:one).to_param, :resource => { }
    assert_template 'edit'
  end
  
end