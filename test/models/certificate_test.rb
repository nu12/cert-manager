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

  test "create" do
    root = Certificate.create({
      :name => "/C=CA/ST=Quebec/L=Montreal/O=nu12/OU=cert-manager/CN=Root CA",
      :expirity_months => 120
    }, {
      :key => keys(:root),
      :password => "cert-manager"
    }, nil)

    assert_not_nil root.content
    assert_equal "Root CA", root.name

  intermediate = Certificate.create({
      :name => "/C=CA/ST=Quebec/L=Montreal/O=nu12/OU=cert-manager/CN=Intermediate CA",
      :expirity_months => 60
    }, {
      :key => keys(:intermediate),
      :password => "cert-manager"
    }, {
      :certificate => certificates(:root),
      :key => keys(:root),
      :password => "cert-manager"
    })

    assert_not_nil intermediate.content
    assert_equal "Intermediate CA", intermediate.name

    server = Certificate.create({
      :name => "/C=CA/ST=Quebec/L=Montreal/O=nu12/OU=cert-manager/CN=Server",
      :expirity_months => 12
    }, {
      :key => keys(:server),
      :password => "cert-manager"
    }, {
      :certificate => certificates(:intermediate),
      :key => keys(:intermediate),
      :password => "cert-manager"
    })

    assert_not_nil server.content
    assert_equal "Server", server.name

  end
end
