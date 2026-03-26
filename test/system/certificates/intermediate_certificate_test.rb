require "application_system_test_case"

class IntermediateCertificatesTest < ApplicationSystemTestCase
  setup do
    visit create_session_url(users(:one).email_address_login_token)
    visit certificates_root_url(certificates(:root))
    within("div#intermediate-card") do
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
    fill_in :common_name, with: "Intermediate System Test"
    select("512", from: "key_size")
    fill_in :password, with: "cert-manager"
    fill_in :validity, with: "60"
    click_on "Save"

    assert_content "Intermediate certificate was successfully created"
  end

  test "create certificate with wrong password" do
    fill_in :authority_password, with: "wrong-password"
    fill_in :country, with: "CA"
    fill_in :state, with: "Quebec"
    fill_in :location, with: "Montreal"
    fill_in :organization, with: "nu12"
    fill_in :organization_unit, with: "cert-manager"
    fill_in :common_name, with: "Intermediate System Test"
    select("512", from: "key_size")
    fill_in :password, with: "cert-manager"
    fill_in :validity, with: "60"
    click_on "Save"

    assert_content "Neither PUB key nor PRIV key"
  end

  test "delete certificate" do
    visit root_url
    click_on certificates(:root).name
    click_on certificates(:intermediate).name
    click_on "Delete"
    click_on "Confirm deletion"
    click_on "Delete certificate"

    assert_content "Certificate was successfully deleted"
  end
end
