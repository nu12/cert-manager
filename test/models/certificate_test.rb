require "test_helper"
require "date"

class CertificateTest < ActiveSupport::TestCase
  test "methods" do
    certificate = Certificate.new
    assert certificate.respond_to? :user
    assert certificate.respond_to? :parent
    assert certificate.respond_to? :children
    assert certificate.respond_to? :is_valid?
  end

  test "is_valid?" do
    valid = Certificate.new(expired_at: DateTime.now + 1.day)
    invalid = Certificate.new(expired_at: DateTime.now - 1.day)

    assert_equal true, valid.is_valid?
    assert_equal false, invalid.is_valid?
  end
end
