require 'test_helper'

class UploadsControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

  test "should post to create" do
    post :create
    assert_response :success
  end

end
