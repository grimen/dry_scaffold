require 'test_helper'

class DucksControllerTest < ActionController::TestCase
  
  context 'create' do
    context 'with success' do
      setup do
        Duck.any_instance.expects(:save).returns(true)
        @duck = Factory(:duck)
        post :create, :duck => @duck.attributes
        @duck = Resource.find(:all).last
      end
      should_assign_to flash[:notice]
      should_redirect_to 'duck_path(@duck)'
    end
    context 'with failure' do
      setup do
        Duck.any_instance.expects(:save).returns(false)
        @duck = Factory(:duck)
        post :create, :duck => @duck.attributes
        @duck = Resource.find(:all).last
      end
      should_assign_to flash[:error]
      should_render_template :new
    end
  end
  
  context 'update' do
    context 'with success' do
      setup do
        Duck.any_instance.expects(:save).returns(true)
        @duck = Factory(:duck)
        put :update, :id => @duck.to_param, :duck => @duck.attributes
      end
      should_assign_to flash[:notice]
      should_redirect_to 'duck_path(@duck)'
    end
    context 'with failure' do
      setup do
        Duck.any_instance.expects(:save).returns(false)
        @duck = Factory(:duck)
        put :update, :id => @duck.to_param, :duck => @duck.attributes
      end
      should_assign_to flash[:error]
      should_render_template :edit
    end
  end
  
  context 'destroy' do
    context 'with success' do
      setup do
        Duck.any_instance.expects(:destroy).returns(true)
        @duck = Factory(:duck)
        delete :destroy, :id => @duck.to_param
      end
      should_assign_to flash[:notice]
      should_redirect_to 'ducks_path'
    end
    # Not possible: destroy with failure
  end
  
  context 'new' do
    setup do
      get :new
    end
    should_respond_with :success
    should_render_template :new
    should_assign_to :duck
  end
  
  context 'edit' do
    setup do
      @duck = Factory(:duck)
      get :edit, :id => @duck.to_param
    end
    should_respond_with :success
    should_render_template :edit
    should_assign_to :duck
  end
  
  context 'show' do
    setup do
      @duck = Factory(:duck)
      get :show, :id => @duck.to_param
    end
    should_respond_with :success
    should_render_template :show
    should_assign_to :duck
  end
  
  context 'index' do
    setup do
      get :index
    end
    should_respond_with :success
    should_assign_to :ducks
  end
  
end
