require "application_system_test_case"

class ExportTest < ApplicationSystemTestCase
  test "root certificate" do
    visit create_session_url(users(:one).email_address_login_token)
    click_on certificates(:root).common_name
    new_window = window_opened_by { click_on "Export certificate" }
    within_window new_window do
      assert_content "-----BEGIN CERTIFICATE-----"
    end
  end
  test "intermediate certificate" do
    visit create_session_url(users(:one).email_address_login_token)
    visit root_url
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    assert_content "Intermediate certificate details (#{certificates(:intermediate).common_name})"
    new_window = window_opened_by { click_on "Export certificate" }
    within_window new_window do
      assert_content "-----BEGIN CERTIFICATE-----"
    end
  end
  test "server certificate" do
    visit create_session_url(users(:one).email_address_login_token)
    visit root_url
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    click_on certificates(:server).common_name, match: :first
    assert_content "Server certificate details (#{certificates(:server).common_name})"
    new_window = window_opened_by { click_on "Export certificate" }
    within_window new_window do
      assert_content "-----BEGIN CERTIFICATE-----"
    end
  end

  test "root key" do
    visit create_session_url(users(:one).email_address_login_token)
    click_on certificates(:root).common_name
    new_window = window_opened_by { click_on "Export key" }
    within_window new_window do
      assert_content "-----BEGIN RSA PRIVATE KEY-----"
    end
  end
  test "intermediate key" do
    visit create_session_url(users(:one).email_address_login_token)
    visit root_url
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    assert_content "Intermediate certificate details (#{certificates(:intermediate).common_name})"
    new_window = window_opened_by { click_on "Export key" }
    within_window new_window do
      assert_content "-----BEGIN RSA PRIVATE KEY-----"
    end
  end
  test "server key" do
    visit create_session_url(users(:one).email_address_login_token)
    visit root_url
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    click_on certificates(:server).common_name, match: :first
    assert_content "Server certificate details (#{certificates(:server).common_name})"
    new_window = window_opened_by { click_on "Export key" }
    within_window new_window do
      assert_content "-----BEGIN RSA PRIVATE KEY-----"
    end
  end

  test "intermediate chain" do
    visit create_session_url(users(:one).email_address_login_token)
    visit root_url
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    assert_content "Intermediate certificate details (#{certificates(:intermediate).common_name})"
    new_window = window_opened_by { click_on "Export chain" }
    within_window new_window do
      assert_content "-----BEGIN CERTIFICATE-----"
    end
  end

  test "server pfx" do
    visit create_session_url(users(:one).email_address_login_token)
    visit root_url
    click_on certificates(:root).common_name
    click_on certificates(:intermediate).common_name
    click_on certificates(:server).common_name, match: :first
    assert_content "Server certificate details (#{certificates(:server).common_name})"
    click_on "Export certificate (.pfx)"
    fill_in "Password", with: "cert-manager"
    new_window = window_opened_by { click_on "Export pfx" }
    within_window new_window do
      assert_content "\u0002\u0001"
    end
  end
end
