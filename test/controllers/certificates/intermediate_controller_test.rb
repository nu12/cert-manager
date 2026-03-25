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

  test "create" do
    authority_password = "cert-manager"
    country = "CA"
    state = "Quebec"
    location = "Montreal"
    organization = "nu12"
    organization_unit = "cert-manager"
    common_name = "Intermediate Test"
    key_size = "512"
    key_password = "cert-manager"
    validity = "60"

    # Missing authority password
    post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: "", country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: "", validity: validity }
    assert_response :unprocessable_content
    assert_select "div.alert", "PEM_write_bio_PrivateKey_traditional: read key"

    # Missing password
    post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: authority_password, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: "", validity: validity }
    assert_response :unprocessable_content
    assert_select "div.alert", "PEM_write_bio_PrivateKey_traditional: read key"

    # Key too small
    post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: authority_password, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: "0", password: key_password, validity: validity }
    assert_response :unprocessable_content
    assert_select "div.alert", "EVP_PKEY_CTX_ctrl_str(ctx, \"rsa_keygen_bits\", \"0\"): key size too small"

    # Missing key size
    post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: authority_password, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: "", password: key_password, validity: validity }
    assert_response :bad_request

    # Missing C
    post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: authority_password, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password, validity: validity }
    assert_response :bad_request

    # Missing ST
    post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: authority_password, country: country, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password, validity: validity }
    assert_response :bad_request

    # Missing L
    post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: authority_password, country: country, state: state, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password, validity: validity }
    assert_response :bad_request

    # Missing O
    post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: authority_password, country: country, state: state, location: location, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password, validity: validity }
    assert_response :bad_request

    # Missing OU
    post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: authority_password, country: country, state: state, location: location, organization: organization, common_name: common_name, key_size: key_size, password: key_password, validity: validity }
    assert_response :bad_request

    # Missing CN
    post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: authority_password, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, key_size: key_size, password: key_password, validity: validity }
    assert_response :bad_request

    # Missing validity
    post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: authority_password, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password }
    assert_response :bad_request

    # Wrong authority password
    post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: "wrong-password", country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password }
    assert_response :bad_request

    assert_difference("Certificate.count") do
      post certificates_root_intermediate_index_url(certificates(:root)), params: { authority_password: authority_password, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, key_size: key_size, password: key_password, validity: validity }
    end

    expected_expirity_date = DateTime.now + (30 * validity.to_i).days

    assert_redirected_to certificates_root_intermediate_url(Certificate.last.parent, Certificate.last)
    assert_equal expected_expirity_date.month, Certificate.last.expired_at.month
    assert_equal expected_expirity_date.day, Certificate.last.expired_at.day
    assert_equal expected_expirity_date.year, Certificate.last.expired_at.year
    assert_notice "Certificate was successfully created"
  end
end
