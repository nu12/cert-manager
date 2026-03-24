require "application_system_test_case"

class ServerCertificatesTest < ApplicationSystemTestCase
  setup do
    visit create_session_url(users(:one).email_address_login_token)
    visit certificates_root_intermediate_url(certificates(:root), certificates(:intermediate))
    within("div#server-card") do
      click_on "New"
    end
  end
  test "create certificate" do
    fill_in :authority_password, with: "cert-manager"
    fill_in :country, with: "CA"
    fill_in :state, with: "Quebec"
    fill_in :location, with: "Montreal"
    fill_in :organization, with: "nu12"
    fill_in :organization_unit, with: "cert-manager"
    fill_in :common_name, with: "Server System Test"
    select("512", from: "key_size")
    fill_in :password, with: "cert-manager"
    fill_in :validity, with: "12"
    click_on "Save"

    assert_content "Certificate was successfully created"
  end

  test "create certificate with wrong password" do
    fill_in :authority_password, with: "wrong-password"
    fill_in :country, with: "CA"
    fill_in :state, with: "Quebec"
    fill_in :location, with: "Montreal"
    fill_in :organization, with: "nu12"
    fill_in :organization_unit, with: "cert-manager"
    fill_in :common_name, with: "Server System Test"
    select("512", from: "key_size")
    fill_in :password, with: "cert-manager"
    fill_in :validity, with: "12"
    click_on "Save"

    assert_content "Neither PUB key nor PRIV key"
  end
end
