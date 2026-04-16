require "application_system_test_case"

class RenewTest < ApplicationSystemTestCase
  test "renew" do
    visit create_session_url(users(:one).email_address_login_token)
    click_on certificates(:root).common_name
    click_on "Renew"
    fill_in "Expirity date", with: "01-01-2030"
    click_on "Save"
    assert_content "Root certificate was successfully created"

    visit renew_url(certificates(:intermediate))
    fill_in "Expirity date", with: "01-01-2030"
    click_on "Save"
    assert_content "Intermediate certificate was successfully created"

    visit renew_url(certificates(:server))
    fill_in "Expirity date", with: "01-01-2030"
    click_on "Save"
    assert_content "Server certificate was successfully created"
  end
end
