require 'test_helper'

class UploadsControllerTest < ActionController::TestCase
  def test_should_get_show
    get :show
    assert_response :success
  end
end
