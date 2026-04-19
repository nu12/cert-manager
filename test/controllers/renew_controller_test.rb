require "test_helper"

class RenewControllerTest < ActionDispatch::IntegrationTest
  include Yaag::Test::SessionsHelper
  setup { sign_in_as(users(:one)) }

  test "root" do
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
end
