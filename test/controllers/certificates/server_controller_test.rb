require "test_helper"

class Certificates::ServerControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  setup { sign_in_as(User.take) }

  test "should get show" do
    get certificates_root_intermediate_server_url(certificates(:root), certificates(:intermediate), certificates(:server))
    assert_response :success
  end
end
