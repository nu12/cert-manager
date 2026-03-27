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

  test "create" do
    authority_id = certificates(:intermediate).id
    authority_password = "cert-manager"
    country = "CA"
    state = "Quebec"
    location = "Montreal"
    organization = "nu12"
    organization_unit = "cert-manager"
    common_name = "Server Test"
    key_size = "512"
    key_password = "cert-manager"
    validity = "12"

    # Missing authority password
    post certificates_url, params: { authority_id: authority_id, authority_password: "", country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: "", validity: validity }
    assert_response :unprocessable_content
    assert_select "div.alert", "PEM_write_bio_PrivateKey_traditional: read key"

    # Missing password
    post certificates_url, params: { authority_id: authority_id, authority_password: authority_password, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: "", validity: validity }
    assert_response :unprocessable_content
    assert_select "div.alert", "PEM_write_bio_PrivateKey_traditional: read key"

    # Key too small
    post certificates_url, params: { authority_id: authority_id, authority_password: authority_password, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: "0", password: key_password, validity: validity }
    assert_response :unprocessable_content
    assert_select "div.alert", "EVP_PKEY_CTX_ctrl_str(ctx, \"rsa_keygen_bits\", \"0\"): key size too small"

    # Missing key size
    post certificates_url, params: { authority_id: authority_id, authority_password: authority_password, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: "", password: key_password, validity: validity }
    assert_response :bad_request

    # Missing C
    post certificates_url, params: { authority_id: authority_id, authority_password: authority_password, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password, validity: validity }
    assert_response :bad_request

    # Missing ST
    post certificates_url, params: { authority_id: authority_id, authority_password: authority_password, country: country, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password, validity: validity }
    assert_response :bad_request

    # Missing L
    post certificates_url, params: { authority_id: authority_id, authority_password: authority_password, country: country, state: state, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password, validity: validity }
    assert_response :bad_request

    # Missing O
    post certificates_url, params: { authority_id: authority_id, authority_password: authority_password, country: country, state: state, location: location, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password, validity: validity }
    assert_response :bad_request

    # Missing OU
    post certificates_url, params: { authority_id: authority_id, authority_password: authority_password, country: country, state: state, location: location, organization: organization, common_name: common_name, key_size: key_size, password: key_password, validity: validity }
    assert_response :bad_request

    # Missing CN
    post certificates_url, params: { authority_id: authority_id, authority_password: authority_password, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, key_size: key_size, password: key_password, validity: validity }
    assert_response :bad_request

    # Missing validity
    post certificates_url, params: { authority_id: authority_id, authority_password: authority_password, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password }
    assert_response :bad_request

    # Wrong authority password
    post certificates_url, params: { authority_id: authority_id, authority_password: "wrong-password", country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password }
    assert_response :bad_request

    assert_difference("Certificate.count") do
      post certificates_url, params: { authority_id: authority_id, authority_password: authority_password, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password, validity: validity }
    end

    expected_expirity_date = DateTime.now + (30 * validity.to_i).days

    assert_redirected_to certificates_root_intermediate_server_url(Certificate.last.parent.parent, Certificate.last.parent, Certificate.last)
    assert_equal expected_expirity_date.month, Certificate.last.expired_at.month
    assert_equal expected_expirity_date.day, Certificate.last.expired_at.day
    assert_equal expected_expirity_date.year, Certificate.last.expired_at.year
    assert_notice "Server certificate was successfully created"
  end

  test "destroy" do
    assert_difference("Certificate.count", -1) do
      delete delete_url(certificates(:server))
    end
    assert_response :see_other
    assert_notice "Certificate was successfully deleted"
  end

  test "destroy keys" do
    # Do not delete key as there is a certificate associate to it
    assert_difference("Key.count", 0) do
      delete delete_url(certificates(:server))
    end

    # Delete key as there is no other certificate associate to it
    assert_difference("Key.count", -1) do
      delete delete_url(certificates(:server_renewed))
    end
  end
end
