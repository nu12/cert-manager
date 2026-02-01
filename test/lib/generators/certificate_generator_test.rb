require "test_helper"
require "generators/certificate/certificate_generator"
require "openssl"

class CertificateGeneratorTest < Rails::Generators::TestCase
  destination_path = "tmp/generators"
  options = %w[--country CA --state Quebec --location Montreal --organization nu12 --organization-unit cert-manager --common-name generator.test]

  tests CertificateGenerator
  destination Rails.root.join(destination_path)
  setup :prepare_destination

  test "generator runs without errors" do
    assert_nothing_raised do
      run_generator options
    end
  end

  test "files are generated" do
    run_generator options

    assert_file "storage/generator.test/root/key.pem"
    assert_file "storage/generator.test/root/cert.pem"

    assert_file "storage/generator.test/intermediate/key.pem"
    assert_file "storage/generator.test/intermediate/cert.pem"

    assert_file "storage/generator.test/server/key.pem"
    assert_file "storage/generator.test/server/cert.pem"
    assert_file "storage/generator.test/server/chain.pem"
  end

  test "certificates are valid" do
    run_generator options

    store = OpenSSL::X509::Store.new
    store.add_file("#{destination_path}/storage/generator.test/root/cert.pem") # To trust self-signed certificate
    cert = OpenSSL::X509::Certificate.new(File.read("#{destination_path}/storage/generator.test/server/cert.pem"))
    intermediate = OpenSSL::X509::Certificate.new(File.read("#{destination_path}/storage/generator.test/intermediate/cert.pem"))
    root = OpenSSL::X509::Certificate.new(File.read("#{destination_path}/storage/generator.test/root/cert.pem"))
    assert store.verify(cert, [ intermediate, root ])

    chain = OpenSSL::X509::Certificate.new(File.read("#{destination_path}/storage/generator.test/server/chain.pem"))
    assert store.verify(cert, [ chain ])
  end
end
