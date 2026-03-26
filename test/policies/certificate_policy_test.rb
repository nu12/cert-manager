require "test_helper"

class CertificatePolicyTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper

  test "no authentication" do
    get certificates_root_index_url
    assert_response :found
    assert_redirected_to new_signin_url
  end

  test "show other's user root certificate" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      get certificates_root_url(certificates(:root))
    end
  end

  test "new root certificate without authentication" do
    get new_certificates_root_url
    assert_response :found
    assert_redirected_to new_signin_url
  end

  test "create root certificate without authentication" do
    post certificates_url, params: { country: "CA", state: "Quebec", location: "Montreal", organization: "nu12", organization_unit: "cert-manager", common_name: "System Test", key_size: "512", password: "cert-manager", validity: "120" }
    assert_response :found
    assert_redirected_to new_signin_url
  end

  test "show other's user intermediate certificate" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      get certificates_root_intermediate_url(certificates(:root), certificates(:intermediate))
    end
  end

  test "new intermediate certificate with other's user root certificate" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      get new_certificates_root_intermediate_url(certificates(:root))
    end
  end

  test "new intermediate certificate with wrong parent certificate" do
    sign_in_as(users(:one))
    assert_raises(ArgumentError) do
      get new_certificates_root_intermediate_url(certificates(:intermediate))
    end

    assert_raises(ArgumentError) do
      get new_certificates_root_intermediate_url(certificates(:server))
    end
  end

  test "create intermediate certificate with other's user root certificate" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      post certificates_url, params: { authority_id: certificates(:root).id, authority_password: "cert-manager", country: "CA", state: "Quebec", location: "Montreal", organization: "nu12", organization_unit: "cert-manager", common_name: "System Test", key_size: "512", password: "cert-manager", validity: "120" }
    end
  end

  test "show other's user server certificate" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      get certificates_root_intermediate_server_url(certificates(:root), certificates(:intermediate), certificates(:server))
    end
  end

  test "new server certificate with other's user intermediate certificate" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      get new_certificates_root_intermediate_server_url(certificates(:root), certificates(:intermediate))
    end
  end

  test "new server certificate with wrong parent certificate" do
    sign_in_as(users(:one))
    assert_raises(ArgumentError) do
      get new_certificates_root_intermediate_server_url(certificates(:root), certificates(:root))
    end

    assert_raises(ArgumentError) do
      get new_certificates_root_intermediate_server_url(certificates(:root), certificates(:server))
    end
  end

  test "create server certificate with other's user intermediate certificate" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      post certificates_url, params: { authority_id: certificates(:intermediate).id, authority_password: "cert-manager", country: "CA", state: "Quebec", location: "Montreal", organization: "nu12", organization_unit: "cert-manager", common_name: "System Test", key_size: "512", password: "cert-manager", validity: "120" }
    end
  end
end
