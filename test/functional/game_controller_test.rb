require 'test_helper'

class GameControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get shoot" do
    get :shoot
    assert_response :success
  end

end
