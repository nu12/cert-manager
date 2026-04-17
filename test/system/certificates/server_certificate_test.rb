require "application_system_test_case"

class ServerCertificatesTest < ApplicationSystemTestCase
  test "create certificate" do
    visit create_session_url(users(:one).email_address_login_token)
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    within("div#server-card") do
      click_on "New"
    end
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
