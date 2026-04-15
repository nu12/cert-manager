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
    fill_in "Country", with: "CA"
    fill_in "State", with: "Quebec"
    fill_in "Location", with: "Montreal"
    fill_in "Organization", with: "nu12"
    fill_in "Organization unit", with: "cert-manager"
    fill_in "Common name", with: "Intermediate System Test"
    fill_in "Expirity date", with: "01-01-2030"
    click_on "Save"

    assert_content "Intermediate certificate was successfully created"
  end
end
