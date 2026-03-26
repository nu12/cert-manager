require "test_helper"
require "date"

class CertificateTest < ActiveSupport::TestCase
  test "methods" do
    certificate = Certificate.new
    assert certificate.respond_to? :user
    assert certificate.respond_to? :parent
    assert certificate.respond_to? :children
    assert certificate.respond_to? :is_valid?
    assert certificate.respond_to? :is_root?
    assert certificate.respond_to? :is_intermediate?
    assert certificate.respond_to? :is_server?
  end

  test "is_valid?" do
    valid = Certificate.new(expired_at: DateTime.now + 1.day)
    invalid = Certificate.new(expired_at: DateTime.now - 1.day)

    assert_equal true, valid.is_valid?
    assert_equal false, invalid.is_valid?
  end

  test "is_root?" do
    certificate = certificates(:root)
    assert_equal true, certificate.is_root?
    assert_equal false, certificate.is_intermediate?
    assert_equal false, certificate.is_server?
  end

  test "is_intermediate?" do
    certificate = certificates(:intermediate)
    assert_equal false, certificate.is_root?
    assert_equal true, certificate.is_intermediate?
    assert_equal false, certificate.is_server?
  end

  test "is_server?" do
    certificate = certificates(:server)
    assert_equal false, certificate.is_root?
    assert_equal false, certificate.is_intermediate?
    assert_equal true, certificate.is_server?
  end

  test "deletion cascade" do
    assert_nothing_raised do
      certificates(:root).destroy!
    end
  end
end
