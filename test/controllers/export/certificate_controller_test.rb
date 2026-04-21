require "test_helper"

class Export::CertificateControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  test "should get show" do
    sign_in_as(users(:one))
    get export_certificate_url(certificates(:root).serial)
    assert_response :success

    get export_certificate_url(certificates(:intermediate).serial)
    assert_response :success

    get export_certificate_url(certificates(:server).serial)
    assert_response :success
  end

  test "no authentication" do
    get export_certificate_url(certificates(:root).serial)
    assert_redirected_to new_signin_url
 
    get export_certificate_url(certificates(:intermediate).serial)
    assert_redirected_to new_signin_url

    get export_certificate_url(certificates(:server).serial)
    assert_redirected_to new_signin_url
  end

  test "wrong user" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      get export_certificate_url(certificates(:root).serial)
    end

    assert_raises(Pundit::NotAuthorizedError) do
      get export_certificate_url(certificates(:intermediate).serial)
    end

    assert_raises(Pundit::NotAuthorizedError) do
      get export_certificate_url(certificates(:server).serial)
    end
  end
end
