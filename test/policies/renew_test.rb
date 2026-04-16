require "test_helper"

class RenewTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper

  test "no authentication" do
    get renew_url(certificates(:root))
    assert_response :found
    assert_redirected_to new_signin_url

    put renew_url(certificates(:root)), params: { id: certificates(:root).id, expirity_date: "2030-01-01" }
    assert_response :found
    assert_redirected_to new_signin_url
  end

  test "show other's user certificate" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      get renew_url(certificates(:root))
    end

    assert_raises(Pundit::NotAuthorizedError) do
      get renew_url(certificates(:intermediate))
    end

    assert_raises(Pundit::NotAuthorizedError) do
      get renew_url(certificates(:server))
    end
  end

  test "update other's user certificate" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      put renew_url(certificates(:root)), params: { id: certificates(:root).id, expirity_date: "2030-01-01" }
    end

    assert_raises(Pundit::NotAuthorizedError) do
      put renew_url(certificates(:intermediate)), params: { id: certificates(:intermediate).id, expirity_date: "2030-01-01" }
    end

    assert_raises(Pundit::NotAuthorizedError) do
      put renew_url(certificates(:server)), params: { id: certificates(:server).id, expirity_date: "2030-01-01" }
    end
  end
end
