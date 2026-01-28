require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  setup { sign_in_as(User.take) }

  test "should get index" do
    get home_index_url
    assert_response :success
  end
end
