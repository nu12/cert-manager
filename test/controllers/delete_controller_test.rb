require "test_helper"

class DeleteControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  setup { sign_in_as(users(:one)) }
  test "show" do
    get delete_url(certificates(:root).serial)
    assert_response :success

    get delete_url(certificates(:intermediate).serial)
    assert_response :success

    get delete_url(certificates(:server).serial)
    assert_response :success
  end
end
