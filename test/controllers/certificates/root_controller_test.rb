require "test_helper"

class RootControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  setup { sign_in_as(users(:one)) }

  test "index" do
    get certificates_root_index_url
    assert_response :success
  end

  test "show" do
    get certificates_root_url(certificates(:root).serial)
    assert_response :success

    assert_raises(ArgumentError) do
      get certificates_root_url(certificates(:intermediate).serial)
    end

    assert_raises(ArgumentError) do
      get certificates_root_url(certificates(:server).serial)
    end
  end

  test "new" do
    get new_certificates_root_url
    assert_response :success
  end

  test "create" do
    country = "CA"
    state = "Quebec"
    location = "Montreal"
    organization = "nu12"
    organization_unit = "cert-manager"
    common_name = "Root Test"
    expirity_date = "2030-01-01"

    # Missing country
    post certificates_url, params: { certificate: { state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, expirity_date: expirity_date } }
    assert_response :unprocessable_content

    # Missing state
    post certificates_url, params: { certificate: { country: country, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, expirity_date: expirity_date } }
    assert_response :unprocessable_content

    # Missing location
    post certificates_url, params: { certificate: { country: country, state: state, organization: organization, organization_unit: organization_unit, common_name: common_name, expirity_date: expirity_date } }
    assert_response :unprocessable_content

    # Missing organization
    post certificates_url, params: { certificate: { country: country, state: state, location: location, organization_unit: organization_unit, common_name: common_name, expirity_date: expirity_date } }
    assert_response :unprocessable_content

    # Missing organization_unit
    post certificates_url, params: { certificate: { country: country, state: state, location: location, organization: organization, common_name: common_name, expirity_date: expirity_date } }
    assert_response :unprocessable_content

    # Missing common_name
    post certificates_url, params: { certificate: { country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, expirity_date: expirity_date } }
    assert_response :unprocessable_content

    # Missing expirity_date
    post certificates_url, params: { certificate: { country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name } }
    assert_response :unprocessable_content

    assert_difference("Certificate.count") do
      post certificates_url, params: { certificate: { country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, expirity_date: expirity_date } }
    end

    assert_redirected_to certificates_root_url(Certificate.last.serial)
    assert_notice "Root certificate was successfully created"
  end

  test "destroy" do
    assert_difference("Certificate.count", 0) do
      delete delete_url(certificates(:root).serial)
    end
    assert_response :see_other
    assert_notice "Certificate cannot be deleted"

    assert_difference("Certificate.count", -4) do
      delete delete_url(certificates(:server).serial)
      delete delete_url(certificates(:server_renewed).serial)
      delete delete_url(certificates(:intermediate).serial)
      delete delete_url(certificates(:root).serial)
    end
    assert_response :see_other
    assert_notice "Certificate was successfully deleted"
  end

  test "destroy keys" do
    assert_difference("Key.count", -3) do
      delete delete_url(certificates(:server).serial)
      delete delete_url(certificates(:server_renewed).serial)
      delete delete_url(certificates(:intermediate).serial)
      delete delete_url(certificates(:root).serial)
    end
  end
end
