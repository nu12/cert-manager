require "test_helper"

class RenewControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper

  test "root" do
    sign_in_as(users(:one))
    root = certificates(:root)
    assert_difference("Certificate.count") do
      put renew_url(root.serial), params: { id: root.id, expirity_date: "2030-01-01" }
    end
    assert_redirected_to certificates_root_url(Certificate.last.serial)
    assert_response :see_other
  end

  test "intermediate" do
  sign_in_as(users(:one))
  intermediate = certificates(:intermediate)
    assert_difference("Certificate.count") do
      put renew_url(intermediate.serial), params: { id: intermediate.id, expirity_date: "2030-01-01" }
    end
    assert_redirected_to certificates_root_intermediate_url(Certificate.last.parent.serial, Certificate.last.serial)
    assert_response :see_other
  end

  test "server" do
  sign_in_as(users(:one))
  server = certificates(:server)
    assert_difference("Certificate.count") do
      put renew_url(server.serial), params: { id: server.id, expirity_date: "2030-01-01" }
    end
    assert_redirected_to certificates_root_intermediate_server_url(Certificate.last.parent.parent.serial, Certificate.last.parent.serial, Certificate.last.serial)
    assert_response :see_other
  end

  test "no authentication" do
    put renew_url(certificates(:root).serial), params: { id: certificates(:root).id, expirity_date: "2030-01-01" }
    assert_response :found
    assert_redirected_to new_signin_url

    put renew_url(certificates(:intermediate).serial), params: { id: certificates(:intermediate).id, expirity_date: "2030-01-01" }
    assert_response :found
    assert_redirected_to new_signin_url

    put renew_url(certificates(:server).serial), params: { id: certificates(:server).id, expirity_date: "2030-01-01" }
    assert_response :found
    assert_redirected_to new_signin_url
  end

  test "update other's user certificate" do
    sign_in_as(users(:two))
    assert_raises(Pundit::NotAuthorizedError) do
      put renew_url(certificates(:root).serial), params: { id: certificates(:root).id, expirity_date: "2030-01-01" }
    end

    assert_raises(Pundit::NotAuthorizedError) do
      put renew_url(certificates(:intermediate).serial), params: { id: certificates(:intermediate).id, expirity_date: "2030-01-01" }
    end

    assert_raises(Pundit::NotAuthorizedError) do
      put renew_url(certificates(:server).serial), params: { id: certificates(:server).id, expirity_date: "2030-01-01" }
    end
  end
end
