require "test_helper"

class Certificates::IntermediateControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  setup { sign_in_as(users(:one)) }

  test "show" do
    get certificates_root_intermediate_url(certificates(:root).serial, certificates(:intermediate).serial)
    assert_response :success

    assert_raises(ArgumentError) do
      get certificates_root_intermediate_url(certificates(:root).serial, certificates(:root).serial)
    end

    assert_raises(ArgumentError) do
      get certificates_root_intermediate_url(certificates(:root).serial, certificates(:server).serial)
    end
  end

  test "create" do
    certificate_id = certificates(:root).id
    country = "CA"
    state = "Quebec"
    location = "Montreal"
    organization = "nu12"
    organization_unit = "cert-manager"
    common_name = "Intermediate Test"
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
      post certificates_url, params: { certificate: { country: country, state: state, location: location, organization: organization, organization_unit: organization_unit, common_name: common_name, expirity_date: expirity_date, certificate_id: certificate_id } }
    end

    assert_redirected_to certificates_root_intermediate_url(Certificate.last.parent.serial, Certificate.last.serial)
    assert_notice "Intermediate certificate was successfully created"
  end

  test "destroy" do
    assert_difference("Certificate.count", 0) do
      delete delete_url(certificates(:intermediate).serial)
    end
    assert_response :see_other
    assert_notice "Certificate cannot be deleted"

    assert_difference("Certificate.count", -3) do
      delete delete_url(certificates(:server).serial)
      delete delete_url(certificates(:server_renewed).serial)
      delete delete_url(certificates(:intermediate).serial)
    end
    assert_response :see_other
    assert_notice "Certificate was successfully deleted"
  end

  test "destroy keys" do
    assert_difference("Key.count", -2) do
      delete delete_url(certificates(:server).serial)
      delete delete_url(certificates(:server_renewed).serial)
      delete delete_url(certificates(:intermediate).serial)
    end
  end
end
