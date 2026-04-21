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
    valid = Certificate.new(expirity_date: DateTime.now + 2.day)
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
    assert_not_nil root.serial
    assert_equal "Root CA", root.common_name
    assert_equal :root, root.type

    intermediate = Certificate.create!(country: "CA", state: "Quebec", location: "Montreal", organization: "nu12", organization_unit: "cert-manager", common_name: "Intermediate CA", expirity_date: "2030-01-01", key: keys(:intermediate), user: users(:one), parent: certificates(:root))
    assert_not_nil intermediate.name
    assert_not_nil intermediate.content
    assert_not_nil intermediate.serial
    assert_equal "Intermediate CA", intermediate.common_name
    assert_equal :intermediate, intermediate.type

    server = Certificate.create!(country: "CA", state: "Quebec", location: "Montreal", organization: "nu12", organization_unit: "cert-manager", common_name: "Server", expirity_date: "2030-01-01", key: keys(:server), user: users(:one), parent: certificates(:intermediate))
    assert_not_nil server.name
    assert_not_nil server.content
    assert_not_nil server.serial
    assert_equal "Server", server.common_name
    assert_equal :server, server.type
  end

  test "type" do
    assert_equal :root, certificates(:root).type
    assert_equal :intermediate, certificates(:intermediate).type
    assert_equal :server, certificates(:server).type
  end

  test "pem" do
    assert_equal "-----BEGIN CERTIFICATE-----\nMIICOTCCAeOgAwIBAgIUZIHP46wqd7Jm6XlxVOnf9z0nuJEwDQYJKoZIhvcNAQEL\nBQAwaTELMAkGA1UEBhMCQ0ExDzANBgNVBAgMBlF1ZWJlYzERMA8GA1UEBwwITW9u\ndHJlYWwxDTALBgNVBAoMBG51MTIxFTATBgNVBAsMDGNlcnQtbWFuYWdlcjEQMA4G\nA1UEAwwHUm9vdCBDQTAeFw0yNjA0MjEwMTIzMTdaFw0yNjAxMDEwMDAwMDBaMGkx\nCzAJBgNVBAYTAkNBMQ8wDQYDVQQIDAZRdWViZWMxETAPBgNVBAcMCE1vbnRyZWFs\nMQ0wCwYDVQQKDARudTEyMRUwEwYDVQQLDAxjZXJ0LW1hbmFnZXIxEDAOBgNVBAMM\nB1Jvb3QgQ0EwXDANBgkqhkiG9w0BAQEFAANLADBIAkEA+0MHoSCftdmSYpaZe8dp\nB0ZpT5avVm3wDWLpb9fviL6k5DldbXpA8bOlOq67/PG/f7GNtDcJinomkvl1KYIg\nEQIDAQABo2MwYTAdBgNVHQ4EFgQU96nZMrz95sn7Pf877olatNX9cWEwHwYDVR0j\nBBgwFoAU96nZMrz95sn7Pf877olatNX9cWEwDwYDVR0TAQH/BAUwAwEB/zAOBgNV\nHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQELBQADQQDNf8HLSI9BH6H5KvavJ6FoQikq\nkg2JoQEmKJROs92T4uBzIVmwDiwRtxhOZnn79ZEhANt/OFseCNCECiwFRVu5\n-----END CERTIFICATE-----\n", certificates(:root).pem
    assert_equal "-----BEGIN CERTIFICATE-----\nMIICMTCCAdugAwIBAgIBADANBgkqhkiG9w0BAQsFADBpMQswCQYDVQQGEwJDQTEP\nMA0GA1UECAwGUXVlYmVjMREwDwYDVQQHDAhNb250cmVhbDENMAsGA1UECgwEbnUx\nMjEVMBMGA1UECwwMY2VydC1tYW5hZ2VyMRAwDgYDVQQDDAdSb290IENBMB4XDTI2\nMDIxMzEzNTQyMVoXDTMxMDIxMjEzNTQyMVowcTELMAkGA1UEBhMCQ0ExDzANBgNV\nBAgMBlF1ZWJlYzERMA8GA1UEBwwITW9udHJlYWwxDTALBgNVBAoMBG51MTIxFTAT\nBgNVBAsMDGNlcnQtbWFuYWdlcjEYMBYGA1UEAwwPSW50ZXJtZWRpYXRlIENBMFww\nDQYJKoZIhvcNAQEBBQADSwAwSAJBALfNwIeYPFd5zPAKMXljEoaVwtCA00ZcnZCu\nl5LMCcqUkEiv0sy4NStEcpONGYXvi1/jKCbwq7gsxRBchdSlcm8CAwEAAaNmMGQw\nHQYDVR0OBBYEFN4yI7GGaPw3DmE6e1tfzSmH47liMB8GA1UdIwQYMBaAFL7ioElJ\nUGs7yAS6f9xiTYrc8OHtMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYDVR0PAQH/BAQD\nAgGGMA0GCSqGSIb3DQEBCwUAA0EAjgxPrpyDd4+IuFh8iVbftR+YW7dSmUkrqjD7\nKoUsZcyeFePGar8Nq9H+b0Rnw7lMbZdG3IkCUGZyQ54qgLfAzg==\n-----END CERTIFICATE-----\n", certificates(:intermediate).pem
    assert_equal "-----BEGIN CERTIFICATE-----\nMIICYTCCAgugAwIBAgIURCAcn5ytligA6ctruxifiZhQKlYwDQYJKoZIhvcNAQEL\nBQAwcTELMAkGA1UEBhMCQ0ExDzANBgNVBAgMBlF1ZWJlYzERMA8GA1UEBwwITW9u\ndHJlYWwxDTALBgNVBAoMBG51MTIxFTATBgNVBAsMDGNlcnQtbWFuYWdlcjEYMBYG\nA1UEAwwPSW50ZXJtZWRpYXRlIENBMB4XDTI2MDQyMTAxMjkzNloXDTI2MDEwMTAw\nMDAwMFowejELMAkGA1UEBhMCQ0ExDzANBgNVBAgMBlF1ZWJlYzERMA8GA1UEBwwI\nTW9udHJlYWwxDTALBgNVBAoMBG51MTIxFTATBgNVBAsMDGNlcnQtbWFuYWdlcjEh\nMB8GA1UEAwwYY2VydC1tYW5hZ2VyLm51MTIuZ2l0aHViMFwwDQYJKoZIhvcNAQEB\nBQADSwAwSAJBAM3ezgcKewUxXA4waDYEXaYy3/c1GuZaD/7ZBpuEOItHd8bJLJxB\n/agKzOYSqG66XQpNUZFxcV4zf99tCQgrmKcCAwEAAaNyMHAwHQYDVR0OBBYEFKrm\n1591eVgkS5KlvsTGH0HuO+9WMB8GA1UdIwQYMBaAFEK2MIEkPyV9xn0VunndxPlu\nsK2nMAkGA1UdEwQCMAAwDgYDVR0PAQH/BAQDAgWgMBMGA1UdJQQMMAoGCCsGAQUF\nBwMBMA0GCSqGSIb3DQEBCwUAA0EAm5+5X2vCbpRgLacs+tL9FxlEg8/tph9i1hvq\nA3lZGauLJYTYlQPyKl9mg/ImFa2nHwwf4jXj9LDDW/wAdojBAg==\n-----END CERTIFICATE-----\n", certificates(:server).pem
  end
end
