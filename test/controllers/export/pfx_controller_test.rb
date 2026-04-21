require "test_helper"

class Export::PfxControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  test "should get create" do
    sign_in_as(users(:one))
    assert_raises(ArgumentError) do
      post export_pfx_index_url(serial: certificates(:root).serial, password: "cert-manager")
    end

    assert_raises(ArgumentError) do
      post export_pfx_index_url(serial: certificates(:intermediate).serial, password: "cert-manager")
    end

    post export_pfx_index_url(serial: certificates(:server).serial, password: "cert-manager")
    assert_response :success
  end

  test "no authentication" do
    post export_pfx_index_url(serial: certificates(:root).serial, password: "cert-manager")
    assert_redirected_to new_signin_url

    post export_pfx_index_url(serial: certificates(:intermediate).serial, password: "cert-manager")
    assert_redirected_to new_signin_url

    post export_pfx_index_url(serial: certificates(:server).serial, password: "cert-manager")
    assert_redirected_to new_signin_url
  end

  test "wrong user" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      post export_pfx_index_url(serial: certificates(:root).serial, password: "cert-manager")
    end

    assert_raises(Pundit::NotAuthorizedError) do
      post export_pfx_index_url(serial: certificates(:intermediate).serial, password: "cert-manager")
    end

    assert_raises(Pundit::NotAuthorizedError) do
      post export_pfx_index_url(serial: certificates(:server).serial, password: "cert-manager")
    end
  end
end
