require "application_system_test_case"

class CertificatesTest < ApplicationSystemTestCase
  test "certificates show" do
    root = certificates(:root)
    intermediate = certificates(:intermediate)
    server = certificates(:server)

    visit create_session_url(users(:one).email_address_login_token)
    assert_content "Home"

    click_on root.name
    assert_content "Root certificate details (#{root.name})"
    assert_content "Export certificate"
    assert_content "Export private key"
    assert_content "Renew"
    assert_content "Delete"

    click_on intermediate.name
    assert_content "Intermediate certificate details (#{intermediate.name})"
    assert_content "Export certificate"
    assert_content "Export private key"
    assert_content "Export chain"
    assert_content "Renew"
    assert_content "Delete"

    click_on server.name
    assert_content "Server certificate details (#{server.name})"
    assert_content "Export certificate (.crt)"
    assert_content "Export private key"
    assert_content "Export certificate (.pfx)"
    assert_content "Renew"
    assert_content "Delete"
  end
end
