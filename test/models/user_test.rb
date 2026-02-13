require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "methods" do
    user = User.take
    assert user.respond_to? :certificates
    assert user.respond_to? :root_certificates

    assert_equal 3, user.certificates.length
    assert_equal 1, user.root_certificates.length
  end
end
