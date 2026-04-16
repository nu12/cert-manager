require "test_helper"

class RenewControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  setup { sign_in_as(users(:one)) }

  test "root" do
    root = certificates(:root)
    get renew_url(root)
    assert_response :success

    assert_difference("Certificate.count") do
      put renew_url(root), params: {id: root.id, expirity_date: "2030-01-01"}
    end
    assert_redirected_to certificates_root_url(Certificate.last)
    assert_response :see_other
  end

  test "intermediate" do
  intermediate = certificates(:intermediate)
    get renew_url(intermediate)
    assert_response :success

    assert_difference("Certificate.count") do
      put renew_url(intermediate), params: {id: intermediate.id, expirity_date: "2030-01-01"}
    end
    assert_redirected_to certificates_root_intermediate_url(Certificate.last.parent, Certificate.last)
    assert_response :see_other
  end

  test "server" do
  server = certificates(:server)
    get renew_url(server)
    assert_response :success

    assert_difference("Certificate.count") do
      put renew_url(server), params: {id: server.id, expirity_date: "2030-01-01"}
    end
    assert_redirected_to certificates_root_intermediate_server_url(Certificate.last.parent.parent, Certificate.last.parent, Certificate.last)
    assert_response :see_other
  end
end
