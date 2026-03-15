require "test_helper"

class CertificatePolicyTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper

  test "should not index" do
    get certificates_root_index_url
    assert_response :found
    assert_redirected_to new_signin_url
  end

  test "should not get show (root)" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      get certificates_root_url(certificates(:root))
    end
  end

  test "should not new (root)" do
    get new_certificates_root_url
    assert_response :found
    assert_redirected_to new_signin_url
  end

  test "should not create (root)" do
    post certificates_root_index_url, params: { country: "CA", state: "Quebec", location: "Montreal", organization: "nu12", organization_unit: "cert-manager", common_name: "System Test", key_size: "512", password: "cert-manager", validity: "120" }
    assert_response :found
    assert_redirected_to new_signin_url
  end

  test "should not get show (intermediate)" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      get certificates_root_intermediate_url(certificates(:root), certificates(:intermediate))
    end
  end

  test "should not get show (server)" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      get certificates_root_intermediate_server_url(certificates(:root), certificates(:intermediate), certificates(:server))
    end
  end
end
