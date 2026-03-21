require "test_helper"

class Certificates::ServerControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  setup { sign_in_as(users(:one)) }

  test "show" do
    get certificates_root_intermediate_server_url(certificates(:root), certificates(:intermediate), certificates(:server))
    assert_response :success

    assert_raises(ArgumentError) do
      get certificates_root_intermediate_server_url(certificates(:root), certificates(:intermediate), certificates(:root))
    end

    assert_raises(ArgumentError) do
      get certificates_root_intermediate_server_url(certificates(:root), certificates(:intermediate), certificates(:intermediate))
    end
  end
end
