require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:user_one)
    sign_in @user
  end

  test "should get dashboard" do
    get root_url
    assert_response :success
  end
end
