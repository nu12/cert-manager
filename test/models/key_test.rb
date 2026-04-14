require "test_helper"

class KeyTest < ActiveSupport::TestCase
  test "methods" do
    key = Key.new
    assert key.respond_to? :user
    assert key.respond_to? :certificates
  end

  test "create" do
    user = users(:one)
    key = Key.create(512, "cert-manager", user)

    assert_equal user.id, key.user.id
    assert_not_nil key.content
  end
end
