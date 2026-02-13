require "test_helper"

class KeyTest < ActiveSupport::TestCase
  test "methods" do
    key = Key.new
    assert key.respond_to? :user
  end
end
