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
    assert certificate.respond_to? :type
  end

  test "is_valid?" do
    valid = Certificate.new(expirity_date: DateTime.now + 1.day)
    invalid = Certificate.new(expirity_date: DateTime.now - 1.day)

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
    root = Certificate.create!(country: "CA", state: "Quebec", location: "Montreal", organization: "nu12", organization_unit: "cert-manager", common_name: "Root CA", expirity_date: "2030-01-01", key: keys(:root), user: users(:one))
    assert_not_nil root.name
    assert_not_nil root.content
    assert_equal "Root CA", root.common_name
    assert_equal :root, root.type

    intermediate = Certificate.create!(country: "CA", state: "Quebec", location: "Montreal", organization: "nu12", organization_unit: "cert-manager", common_name: "Intermediate CA", expirity_date: "2030-01-01", key: keys(:intermediate), user: users(:one), parent: certificates(:root))
    assert_not_nil intermediate.name
    assert_not_nil intermediate.content
    assert_equal "Intermediate CA", intermediate.common_name
    assert_equal :intermediate, intermediate.type

    server = Certificate.create!(country: "CA", state: "Quebec", location: "Montreal", organization: "nu12", organization_unit: "cert-manager", common_name: "Server", expirity_date: "2030-01-01", key: keys(:server), user: users(:one), parent: certificates(:intermediate))
    assert_not_nil server.name
    assert_not_nil server.content
    assert_equal "Server", server.common_name
    assert_equal :server, server.type
  end

  test "type" do
    assert_equal :root, certificates(:root).type
    assert_equal :intermediate, certificates(:intermediate).type
    assert_equal :server, certificates(:server).type
  end
end
