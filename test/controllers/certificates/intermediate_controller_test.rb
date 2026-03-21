require "test_helper"

class Certificates::IntermediateControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  setup { sign_in_as(users(:one)) }

  test "show" do
    get certificates_root_intermediate_url(certificates(:root), certificates(:intermediate))
    assert_response :success

    assert_raises(ArgumentError) do
      get certificates_root_intermediate_url(certificates(:root), certificates(:root))
    end

    assert_raises(ArgumentError) do
      get certificates_root_intermediate_url(certificates(:root), certificates(:server))
    end
  end
end
