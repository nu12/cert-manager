require "application_system_test_case"

class RootCertificatesTest < ApplicationSystemTestCase
  test "create certificate" do
    visit create_session_url(User.take.email_address_login_token)
    find('a#new-root-link').click
    fill_in "Country", with: "CA"
    fill_in "State", with: "Quebec"
    fill_in "Location", with: "Montreal"
    fill_in "Organization", with: "nu12"
    fill_in "Organization unit", with: "cert-manager"
    fill_in "Common name", with: "Root System Test"
    fill_in "Expirity date", with: "01-01-2030"
    click_on "Save"

    assert_content "Root certificate was successfully created"
  end
end
