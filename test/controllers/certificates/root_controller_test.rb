require "test_helper"

class RootControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  setup { sign_in_as(User.take) }

  test "should get index" do
    get certificates_root_index_url
    assert_response :success
  end

  test "should get show" do
    get certificates_root_url(certificates(:root))
    assert_response :success
  end
end
