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
    assert_equal "-----BEGIN CERTIFICATE-----\nMIICOTCCAeOgAwIBAgIUaqxMf/NTxkYatLHEYRjKUogs6m0wDQYJKoZIhvcNAQEL\nBQAwaTELMAkGA1UEBhMCQ0ExDzANBgNVBAgMBlF1ZWJlYzERMA8GA1UEBwwITW9u\ndHJlYWwxDTALBgNVBAoMBG51MTIxFTATBgNVBAsMDGNlcnQtbWFuYWdlcjEQMA4G\nA1UEAwwHUm9vdCBDQTAeFw0yNjA0MjEwMzAyMjdaFw0yNjAxMDEwMDAwMDBaMGkx\nCzAJBgNVBAYTAkNBMQ8wDQYDVQQIDAZRdWViZWMxETAPBgNVBAcMCE1vbnRyZWFs\nMQ0wCwYDVQQKDARudTEyMRUwEwYDVQQLDAxjZXJ0LW1hbmFnZXIxEDAOBgNVBAMM\nB1Jvb3QgQ0EwXDANBgkqhkiG9w0BAQEFAANLADBIAkEA1m/LhE9jMejwBqc4mOk2\nWDvh8jtfNGgv4Yw6bRs4CS3JztD4vuEaV0CVCPWBeYdQjwCa6J3Ew6Zv5hgvplhI\nOQIDAQABo2MwYTAdBgNVHQ4EFgQUNWifvvXfzKIKJjTUZJMbDBO8Kn0wHwYDVR0j\nBBgwFoAUNWifvvXfzKIKJjTUZJMbDBO8Kn0wDwYDVR0TAQH/BAUwAwEB/zAOBgNV\nHQ8BAf8EBAMCAQYwDQYJKoZIhvcNAQELBQADQQAlstg/wd2zcbqbbBNdFNz3aZ2m\npEZ3uOts06QnXJ9Y1K2C4g3IHR8HSiQ7xNDlKYaqEfbgX9Q+qYVO2Je8J31Q\n-----END CERTIFICATE-----\n", certificates(:root).pem
    assert_equal "-----BEGIN CERTIFICATE-----\nMIICRDCCAe6gAwIBAgIUSklhrx+sB2atjqwRbbQF3pNTlkcwDQYJKoZIhvcNAQEL\nBQAwaTELMAkGA1UEBhMCQ0ExDzANBgNVBAgMBlF1ZWJlYzERMA8GA1UEBwwITW9u\ndHJlYWwxDTALBgNVBAoMBG51MTIxFTATBgNVBAsMDGNlcnQtbWFuYWdlcjEQMA4G\nA1UEAwwHUm9vdCBDQTAeFw0yNjA0MjEwMzA0MzZaFw0yNjAxMDEwMDAwMDBaMHEx\nCzAJBgNVBAYTAkNBMQ8wDQYDVQQIDAZRdWViZWMxETAPBgNVBAcMCE1vbnRyZWFs\nMQ0wCwYDVQQKDARudTEyMRUwEwYDVQQLDAxjZXJ0LW1hbmFnZXIxGDAWBgNVBAMM\nD0ludGVybWVkaWF0ZSBDQTBcMA0GCSqGSIb3DQEBAQUAA0sAMEgCQQDNbszE7ECN\npTrv14or6aoxo1DU+88dQiQba2UTNviA73KgmN2dLvcNbcjHKQItzRKx1oYmNkEe\nMloTRXCpNjpDAgMBAAGjZjBkMB0GA1UdDgQWBBR+uRmMo6KFgeyYfVZ3WQEpi22X\n+zAfBgNVHSMEGDAWgBQ1aJ++9d/MogomNNRkkxsME7wqfTASBgNVHRMBAf8ECDAG\nAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjANBgkqhkiG9w0BAQsFAANBAEHzeT91M7e7\n+D/lFX1bC0a3qiYs4IHsz7jpBIKdqya6eM8/JgB+NqzS7XtbmfUaUXu3D8sRPztR\nXg6NvTfpIZc=\n-----END CERTIFICATE-----\n", certificates(:intermediate).pem
    assert_equal "-----BEGIN CERTIFICATE-----\nMIICYjCCAgygAwIBAgIVAMD8AJa/G0WDJuZeZL5GcqiEWvUPMA0GCSqGSIb3DQEB\nCwUAMHExCzAJBgNVBAYTAkNBMQ8wDQYDVQQIDAZRdWViZWMxETAPBgNVBAcMCE1v\nbnRyZWFsMQ0wCwYDVQQKDARudTEyMRUwEwYDVQQLDAxjZXJ0LW1hbmFnZXIxGDAW\nBgNVBAMMD0ludGVybWVkaWF0ZSBDQTAeFw0yNjA0MjEwMzA1NTFaFw0yNjAxMDEw\nMDAwMDBaMHoxCzAJBgNVBAYTAkNBMQ8wDQYDVQQIDAZRdWViZWMxETAPBgNVBAcM\nCE1vbnRyZWFsMQ0wCwYDVQQKDARudTEyMRUwEwYDVQQLDAxjZXJ0LW1hbmFnZXIx\nITAfBgNVBAMMGGNlcnQtbWFuYWdlci5udTEyLmdpdGh1YjBcMA0GCSqGSIb3DQEB\nAQUAA0sAMEgCQQC1D0P0GE6osFHEBU6dXjCcdj1jhZN61T/rKYsxd1LXhgoIFaqh\nFW3JmxQr6v9WJFfUrTLn7GN/Vwx6bHRh5TwFAgMBAAGjcjBwMB0GA1UdDgQWBBQY\n6RK1yG3J2s+Th9S7BN3AwDBcRzAfBgNVHSMEGDAWgBR+uRmMo6KFgeyYfVZ3WQEp\ni22X+zAJBgNVHRMEAjAAMA4GA1UdDwEB/wQEAwIFoDATBgNVHSUEDDAKBggrBgEF\nBQcDATANBgkqhkiG9w0BAQsFAANBAHApIZEhbrfRcuq6MPaxc+zLpsN45/BWTUV8\nUS1dPeQTfJBt9IcATCoxHYqA0tmBX7DRLc1V2LmaelxxmeAdZX0=\n-----END CERTIFICATE-----\n", certificates(:server).pem
  end

  test "presence" do
    required = [ :country, :state, :location, :organization, :organization_unit, :common_name, :expirity_date ]
    params = {
      country: "Ok",
      state: "Ok",
      location: "Ok",
      organization: "Ok",
      organization_unit: "Ok",
      common_name: "Ok",
      expirity_date: "2030-01-01",
      key: keys(:root),
      user: users(:one)
    }
    assert Certificate.new(params).valid?
    required.each do | r |
      assert Certificate.new(params.reject { |k, v| k == r }).invalid?
    end
  end
end
