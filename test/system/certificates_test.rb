require "application_system_test_case"

class SigninsTest < ApplicationSystemTestCase
  test "certificates show" do
    root = certificates(:root)
    intermediate = certificates(:intermediate)
    server = certificates(:server)

    visit create_session_url(User.take.email_address_login_token)
    assert_content "Home"

    click_on root.name
    assert_content "Root certificate details (#{root.name})"

    click_on intermediate.name
    assert_content "Intermediate certificate details (#{intermediate.name})"

    click_on server.name
    assert_content "Server certificate details (#{server.name})"
  end
end
