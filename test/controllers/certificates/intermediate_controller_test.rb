require "test_helper"

class Certificates::IntermediateControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  setup { sign_in_as(User.take) }

  test "should get show" do
    get certificates_root_intermediate_url(certificates(:root), certificates(:intermediate))
    assert_response :success
  end
end
