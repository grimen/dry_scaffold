require 'test_helper'

class DucksControllerTest < ActionController::TestCase
  
  test 'create' do
    Duck.any_instance.expects(:save).returns(true)
    @duck = ducks(:basic)
    post :create, :duck => @duck.attributes
    assert_not_nil flash[:notice]
    assert_response :redirect
  end
  
  test 'create with failure' do
    Duck.any_instance.expects(:save).returns(false)
    @duck = ducks(:basic)
    post :create, :duck => @duck.attributes
    assert_not_nil flash[:error]
    assert_template 'new'
  end
  
  test 'update' do
    Duck.any_instance.expects(:save).returns(true)
    @duck = ducks(:basic)
    put :update, :id => @duck.to_param, :duck => @duck.attributes
    assert_not_nil flash[:notice]
    assert_response :redirect
  end
  
  test 'update with failure' do
    Duck.any_instance.expects(:save).returns(false)
    @duck = ducks(:basic)
    put :update, :id => @duck.to_param, :duck => @duck.attributes
    assert_not_nil flash[:error]
    assert_template 'edit'
  end
  
  test 'destroy' do
    Duck.any_instance.expects(:destroy).returns(true)
    @duck = ducks(:basic)
    delete :destroy, :id => @duck.to_param
    assert_not_nil flash[:notice]
    assert_response :redirect
  end
  
  # Not possible: destroy with failure
  
  test 'new' do
    get :new
    assert_response :success
  end
  
  test 'edit' do
    @duck = ducks(:basic)
    get :edit, :id => @duck.to_param
    assert_response :success
  end
  
  test 'show' do
    @duck = ducks(:basic)
    get :show, :id => @duck.to_param
    assert_response :success
  end
  
  test 'index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:ducks)
  end
  
end