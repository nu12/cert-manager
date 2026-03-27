require "test_helper"

class KeyTest < ActiveSupport::TestCase
  test "methods" do
    key = Key.new
    assert key.respond_to? :user
    assert key.respond_to? :certificates
  end
end
