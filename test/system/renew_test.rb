require "application_system_test_case"

class RenewTest < ApplicationSystemTestCase
  test "root" do
    visit create_session_url(users(:one).email_address_login_token)
    click_on certificates(:root).common_name
    assert_content certificates(:root).common_name
    click_on "Renew"
    fill_in "Expirity date", with: "01-01-2030"
    click_on "Save"
    assert_content "Root certificate was successfully created"
  end

  test "intermediate" do
    visit create_session_url(users(:one).email_address_login_token)
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    assert_content certificates(:intermediate).common_name
    assert_content "Intermediate certificate details (#{certificates(:intermediate).common_name})"
    click_on "Renew"
    fill_in "Expirity date", with: "01-01-2030"
    click_on "Save"
    assert_content "Intermediate certificate was successfully created"
  end

  test "server" do
    visit create_session_url(users(:one).email_address_login_token)
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    click_on certificates(:server).common_name, match: :first
    assert_content "Server certificate details (#{certificates(:server).common_name})"
    click_on "Renew"
    fill_in "Expirity date", with: "01-01-2030"
    click_on "Save"
    assert_content "Server certificate was successfully created"
  end
end
