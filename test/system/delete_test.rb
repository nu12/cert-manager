require "application_system_test_case"

class DeleteTest < ApplicationSystemTestCase
  test "delete" do
    visit create_session_url(users(:one).email_address_login_token)
    click_on certificates(:root).name
    click_on "Delete"
    click_on "Confirm deletion"
    click_on "Delete certificate"
    assert_content "Certificate cannot be deleted"

    visit delete_url certificates(:intermediate)
    click_on "Confirm deletion"
    click_on "Delete certificate"
    assert_content "Certificate cannot be deleted"

    visit delete_url certificates(:server)
    click_on "Confirm deletion"
    click_on "Delete certificate"
    assert_content "Certificate was successfully deleted"

    visit delete_url certificates(:server_renewed)
    click_on "Confirm deletion"
    click_on "Delete certificate"
    assert_content "Certificate was successfully deleted"

    visit delete_url certificates(:intermediate)
    click_on "Confirm deletion"
    click_on "Delete certificate"
    assert_content "Certificate was successfully deleted"

    visit root_url
    click_on certificates(:root).name
    click_on "Delete"
    click_on "Confirm deletion"
    click_on "Delete certificate"
    assert_content "Certificate was successfully deleted"
  end
end
