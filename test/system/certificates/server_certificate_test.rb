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
    fill_in "Country", with: "CA"
    fill_in "State", with: "Quebec"
    fill_in "Location", with: "Montreal"
    fill_in "Organization", with: "nu12"
    fill_in "Organization unit", with: "cert-manager"
    fill_in "Common name", with: "Server System Test"
    fill_in "Expirity date", with: "01-01-2030"
    click_on "Save"

    assert_content "Server certificate was successfully created"
  end
end
