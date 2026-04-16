require "application_system_test_case"

class DeleteTest < ApplicationSystemTestCase
  test "delete" do
    visit create_session_url(users(:one).email_address_login_token)
    click_on certificates(:root).common_name
    click_on "Delete"
    click_on "Confirm deletion"
    click_on "Delete certificate"
    assert_content "Certificate cannot be deleted"

    visit root_url
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    assert_content "Intermediate certificate details (#{certificates(:intermediate).common_name})"
    click_on "Delete"
    click_on "Confirm deletion"
    click_on "Delete certificate"
    assert_content "Certificate cannot be deleted"

    visit root_url
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    click_on certificates(:server).common_name, match: :first
    assert_content "Server certificate details (#{certificates(:server).common_name})"
    click_on "Delete"
    click_on "Confirm deletion"
    click_on "Delete certificate"
    assert_content "Certificate was successfully deleted"

    visit root_url
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    click_on certificates(:server_renewed).common_name, match: :first
    assert_content "Server certificate details (#{certificates(:server_renewed).common_name})"
    click_on "Delete"
    click_on "Confirm deletion"
    click_on "Delete certificate"
    assert_content "Certificate was successfully deleted"

    visit root_url
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    assert_content "Intermediate certificate details (#{certificates(:intermediate).common_name})"
    click_on "Delete"
    click_on "Confirm deletion"
    click_on "Delete certificate"
    assert_content "Certificate was successfully deleted"

    visit root_url
    click_on certificates(:root).common_name
    click_on "Delete"
    click_on "Confirm deletion"
    click_on "Delete certificate"
    assert_content "Certificate was successfully deleted"
  end
end
