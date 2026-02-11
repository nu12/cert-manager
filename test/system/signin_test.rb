require "application_system_test_case"

class RegistrationsTest < ApplicationSystemTestCase
  test "new sign in" do
    visit new_signin_url
    assert_content "Sign In"

    fill_in "email_address", with: User.take.email_address
    click_on "Sign in"
    assert_content "Sign in address sent to provided e-mail"
  end

  test "create session" do
    visit create_session_url(User.take.email_address_login_token)
    assert_content "Signed in successfully"
  end
end
