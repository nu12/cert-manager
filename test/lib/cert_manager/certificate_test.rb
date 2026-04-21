require "test_helper"
require "cert_manager/certificate"
require "openssl"

class CertManagerCertificateTest < ActionDispatch::IntegrationTest
  test "methods" do
    # assert CertManager::Certificate.respond_to? :create
    assert CertManager::Certificate.respond_to? :create_root
    assert CertManager::Certificate.respond_to? :create_intermediate
    assert CertManager::Certificate.respond_to? :create_server
    assert CertManager::Certificate.respond_to? :import
    assert CertManager::Certificate.respond_to? :parse
  end

  test "create_root" do
    key = CertManager::Key.parse(keys(:root))
    raw = CertManager::Certificate.create_root(key, "/C=CA/ST=Quebec/L=Montreal/O=nu12/OU=cert-manager/CN=Root CA")
    assert raw.include? "-----BEGIN CERTIFICATE-----\n"

    cert = OpenSSL::X509::Certificate.new raw
    assert_equal 4, cert.extensions.size
    assert_equal "subjectKeyIdentifier", cert.extensions[0].oid
    assert_equal "35:68:9F:BE:F5:DF:CC:A2:0A:26:34:D4:64:93:1B:0C:13:BC:2A:7D", cert.extensions[0].value
    assert_equal "authorityKeyIdentifier", cert.extensions[1].oid
    assert_equal "35:68:9F:BE:F5:DF:CC:A2:0A:26:34:D4:64:93:1B:0C:13:BC:2A:7D", cert.extensions[1].value
    assert_equal "basicConstraints", cert.extensions[2].oid
    assert_equal "CA:TRUE", cert.extensions[2].value
    assert_equal "keyUsage", cert.extensions[3].oid
    assert_equal "Certificate Sign, CRL Sign", cert.extensions[3].value
    assert_equal OpenSSL::X509::Name, cert.subject.class
  end

  test "create_intermediate" do
    key = CertManager::Key.parse(keys(:intermediate))
    root_cert = CertManager::Certificate.parse(certificates(:root))
    root_key = CertManager::Key.parse(certificates(:root).key)
    raw = CertManager::Certificate.create_intermediate(key, "/C=CA/ST=Quebec/L=Montreal/O=nu12/OU=cert-manager/CN=Intermediate CA", root_cert, root_key)
    assert raw.include? "-----BEGIN CERTIFICATE-----\n"

    cert = OpenSSL::X509::Certificate.new raw
    assert_equal 4, cert.extensions.size
    assert_equal "subjectKeyIdentifier", cert.extensions[0].oid
    assert_equal "7E:B9:19:8C:A3:A2:85:81:EC:98:7D:56:77:59:01:29:8B:6D:97:FB", cert.extensions[0].value
    assert_equal "authorityKeyIdentifier", cert.extensions[1].oid
    assert_equal "35:68:9F:BE:F5:DF:CC:A2:0A:26:34:D4:64:93:1B:0C:13:BC:2A:7D", cert.extensions[1].value
    assert_equal "basicConstraints", cert.extensions[2].oid
    assert_equal "CA:TRUE, pathlen:0", cert.extensions[2].value
    assert_equal "keyUsage", cert.extensions[3].oid
    assert_equal "Digital Signature, Certificate Sign, CRL Sign", cert.extensions[3].value
    assert_equal OpenSSL::X509::Name, cert.subject.class
  end

  test "create_server" do
    key = CertManager::Key.parse(keys(:server))
    inter_cert = CertManager::Certificate.parse(certificates(:intermediate))
    inter_key = CertManager::Key.parse(certificates(:intermediate).key)
    raw = CertManager::Certificate.create_server(key, "/C=CA/ST=Quebec/L=Montreal/O=nu12/OU=cert-manager/CN=cert-manager.github.nu12", inter_cert, inter_key)
    assert raw.include? "-----BEGIN CERTIFICATE-----\n"

    cert = OpenSSL::X509::Certificate.new raw
    assert_equal 5, cert.extensions.size
    assert_equal "subjectKeyIdentifier", cert.extensions[0].oid
    assert_equal "18:E9:12:B5:C8:6D:C9:DA:CF:93:87:D4:BB:04:DD:C0:C0:30:5C:47", cert.extensions[0].value
    assert_equal "authorityKeyIdentifier", cert.extensions[1].oid
    assert_equal "7E:B9:19:8C:A3:A2:85:81:EC:98:7D:56:77:59:01:29:8B:6D:97:FB", cert.extensions[1].value
    assert_equal "basicConstraints", cert.extensions[2].oid
    assert_equal "CA:FALSE", cert.extensions[2].value
    assert_equal "keyUsage", cert.extensions[3].oid
    assert_equal "Digital Signature, Key Encipherment", cert.extensions[3].value
    assert_equal "extendedKeyUsage", cert.extensions[4].oid
    assert_equal "TLS Web Server Authentication", cert.extensions[4].value
    assert_equal OpenSSL::X509::Name, cert.subject.class
  end

  test "import" do
    cert = CertManager::Certificate.import(File.read("test/fixtures/files/certificate.pem"))
    assert cert.include? "-----BEGIN CERTIFICATE-----\n"
  end

  test "parse" do
    cert = CertManager::Certificate.parse(certificates(:server))
    assert cert.respond_to? :extensions
    assert cert.respond_to? :verify
    assert cert.respond_to? :subject
    assert cert.respond_to? :issuer
  end
end
