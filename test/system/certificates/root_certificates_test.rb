require "application_system_test_case"

class RootCertificatesTest < ApplicationSystemTestCase
  test "create certificate" do
    visit create_session_url(User.take.email_address_login_token)
    within("div#root-card") do
      click_on "New"
    end

    fill_in :country, with: "CA"
    fill_in :state, with: "Quebec"
    fill_in :location, with: "Montreal"
    fill_in :organization, with: "nu12"
    fill_in :organization_unit, with: "cert-manager"
    fill_in :common_name, with: "Root System Test"
    select("512", from: "key_size")
    fill_in :password, with: "cert-manager"
    fill_in :validity, with: "120"
    click_on "Save"

    assert_content "Root certificate was successfully created"
  end
end
