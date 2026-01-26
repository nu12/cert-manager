ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

##################
# TODO: ModelStub to be replaced with real model
class ModelStub
  def content
    "-----BEGIN RSA PRIVATE KEY-----\nProc-Type: 4,ENCRYPTED\nDEK-Info: AES-128-CBC,4918894FFFFBDAE8CA0B1FA56697B788\n\nz+x7n7dR8QyNrDDN8OdXLdi/0YriS4rOg9ZD7tmRDk3IH2acYMWEfi/mrMFMpYIH\ni/TsM0zE7Xlvu6+Z7A370tdRWO+jMUprDHzD9AAWMlRwnCuhmYF+hW/n94uPDbwK\nEUaT5Yc4lxufPdJsN77qFG9/f4lcuBziWUKn2B7cii4K5tSpeRgsKMH/tvXT5Dex\nNSu7hVhJudGvHJa0WPFOhIcaqfQlY6tYT1h0gUC/jqDDUEzELggcm786c0kWq3Hg\nVi2JtXuMYdHkb3RwPH8I4Y34LtHeAkgyDJfly/lB8TSrSAKUd/prc03UlEZm7MPR\nsucxtIXlqoIeETYOzaKD8k0el3MyWVv1mCM0mejwkRxJU1BPT296M8bqNUwl4WuW\ny5QeyNiygYfapHE3f7vPtYnitkuxLsltbN0i3GfpD7I=\n-----END RSA PRIVATE KEY-----\n"
  end
end
class CertificateStub
  def content
    "-----BEGIN CERTIFICATE-----\nMIICfzCCAikCAQAwDQYJKoZIhvcNAQELBQAwaTELMAkGA1UEBhMCQ0ExDzANBgNV\nBAgMBlF1ZWJlYzERMA8GA1UEBwwITW9udHJlYWwxDTALBgNVBAoMBG51MTIxFTAT\nBgNVBAsMDGNlcnQtbWFuYWdlcjEQMA4GA1UEAwwHUm9vdCBDQTAeFw0yNjAxMjQx\nOTI0MTlaFw0zNjAxMjIxOTI0MTlaMGkxCzAJBgNVBAYTAkNBMQ8wDQYDVQQIDAZR\ndWViZWMxETAPBgNVBAcMCE1vbnRyZWFsMQ0wCwYDVQQKDARudTEyMRUwEwYDVQQL\nDAxjZXJ0LW1hbmFnZXIxEDAOBgNVBAMMB1Jvb3QgQ0EwXDANBgkqhkiG9w0BAQEF\nAANLADBIAkEAzrk/xNc3Px0og3NXApNQVIrb9qkguEgPSlyyZaM4sYzVEFC7Eujv\n+9rjUOXnNfkr+Jh/8D/nWkuKoNFvC0d2qQIDAQABo4HAMIG9MB0GA1UdDgQWBBS+\n4qBJSVBrO8gEun/cYk2K3PDh7TB7BgNVHSMEdDByoW2kazBpMQswCQYDVQQGEwJD\nQTEPMA0GA1UECAwGUXVlYmVjMREwDwYDVQQHDAhNb250cmVhbDENMAsGA1UECgwE\nbnUxMjEVMBMGA1UECwwMY2VydC1tYW5hZ2VyMRAwDgYDVQQDDAdSb290IENBggEA\nMA8GA1UdEwEB/wQFMAMBAf8wDgYDVR0PAQH/BAQDAgEGMA0GCSqGSIb3DQEBCwUA\nA0EAVONUfDM5pkZMgX27HQrqvtaPh7IjlH60OatQINuC1j1T0viClBvrQM1YwYRZ\nVWvDh/h44Bmnsx66qqiJ8nk4Ng==\n-----END CERTIFICATE-----\n"
  end
  def key
    ModelStub.new
  end
end
##################