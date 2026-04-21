require "test_helper"

class Certificates::ServerControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  setup { sign_in_as(users(:one)) }

  test "show" do
    get certificates_root_intermediate_server_url(certificates(:root).serial, certificates(:intermediate).serial, certificates(:server).serial)
    assert_response :success

    assert_raises(ArgumentError) do
      get certificates_root_intermediate_server_url(certificates(:root).serial, certificates(:intermediate).serial, certificates(:root).serial)
    end

    assert_raises(ArgumentError) do
      get certificates_root_intermediate_server_url(certificates(:root).serial, certificates(:intermediate).serial, certificates(:intermediate).serial)
    end
  end

  test "create" do
    certificate_id = certificates(:intermediate).id
    country = "CA"
    state = "Quebec"
    location = "Montreal"
    organization = "nu12"
    organization_unit = "cert-manager"
    common_name = "Server Test"
    expirity_date = "2030-01-01"

    # Missing country
    post certificates_url, params: { certificate: { state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, expirity_date: expirity_date, certificate_id: certificate_id } }
    assert_response :unprocessable_content

    # Missing state
    post certificates_url, params: { certificate: { country: country, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, expirity_date: expirity_date, certificate_id: certificate_id } }
    assert_response :unprocessable_content

    # Missing location
    post certificates_url, params: { certificate: { country: country, state: state, organization: organization, organization_unit: organization_unit, common_name: common_name, expirity_date: expirity_date, certificate_id: certificate_id } }
    assert_response :unprocessable_content

    # Missing organization
    post certificates_url, params: { certificate: { country: country, state: state, location: location, organization_unit: organization_unit, common_name: common_name, expirity_date: expirity_date, certificate_id: certificate_id } }
    assert_response :unprocessable_content

    # Missing organization_unit
    post certificates_url, params: { certificate: { country: country, state: state, location: location, organization: organization, common_name: common_name, expirity_date: expirity_date, certificate_id: certificate_id } }
    assert_response :unprocessable_content

    # Missing common_name
    post certificates_url, params: { certificate: { country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, expirity_date: expirity_date, certificate_id: certificate_id } }
    assert_response :unprocessable_content

    # Missing expirity_date
    post certificates_url, params: { certificate: { country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, certificate_id: certificate_id } }
    assert_response :unprocessable_content

    assert_difference("Certificate.count") do
      post certificates_url, params: { certificate: { certificate_id: certificate_id, country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, expirity_date: expirity_date } }
    end

    assert_redirected_to certificates_root_intermediate_server_url(Certificate.last.parent.parent.serial, Certificate.last.parent.serial, Certificate.last.serial)
    assert_notice "Server certificate was successfully created"
  end

  test "destroy" do
    assert_difference("Certificate.count", -1) do
      delete delete_url(certificates(:server).serial)
    end
    assert_response :see_other
    assert_notice "Certificate was successfully deleted"
  end

  test "destroy keys" do
    # Do not delete key as there is a certificate associate to it
    assert_difference("Key.count", 0) do
      delete delete_url(certificates(:server).serial)
    end

    # Delete key as there is no other certificate associate to it
    assert_difference("Key.count", -1) do
      delete delete_url(certificates(:server_renewed).serial)
    end
  end
end
