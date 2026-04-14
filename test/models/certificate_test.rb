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
    assert certificate.respond_to? :subject
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

  test "subject" do
    key = keys(:root)
    certificate = Certificate.create!(content: CertManager::Certificate.create_root(CertManager::Key.parse(key, "cert-manager"), "/C=CA/ST=Quebec/L=Montreal/O=nu12/OU=cert-manager/CN=subject-test", 0, 0), name: "subject-test", user: users(:one), key: key, expired_at: Date.today)
    assert_equal "BE:E2:A0:49:49:50:6B:3B:C8:04:BA:7F:DC:62:4D:8A:DC:F0:E1:ED", certificate.subject

    assert_equal "BE:E2:A0:49:49:50:6B:3B:C8:04:BA:7F:DC:62:4D:8A:DC:F0:E1:ED", certificates(:root).subject
    assert_equal "DE:32:23:B1:86:68:FC:37:0E:61:3A:7B:5B:5F:CD:29:87:E3:B9:62", certificates(:intermediate).subject
    assert_equal "88:4B:8A:BA:ED:B2:C2:5A:87:57:BE:4C:9C:8F:32:A1:27:61:A0:CB", certificates(:server).subject
    assert_equal "84:A4:16:11:74:82:10:6B:9D:8D:BF:8E:77:93:FA:35:07:54:8C:01", certificates(:server_renewed).subject
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
