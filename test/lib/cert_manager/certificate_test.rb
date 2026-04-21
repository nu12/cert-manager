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
    assert_equal "F7:A9:D9:32:BC:FD:E6:C9:FB:3D:FF:3B:EE:89:5A:B4:D5:FD:71:61", cert.extensions[0].value
    assert_equal "authorityKeyIdentifier", cert.extensions[1].oid
    assert_equal "F7:A9:D9:32:BC:FD:E6:C9:FB:3D:FF:3B:EE:89:5A:B4:D5:FD:71:61", cert.extensions[1].value
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
    assert_equal "42:B6:30:81:24:3F:25:7D:C6:7D:15:BA:79:DD:C4:F9:6E:B0:AD:A7", cert.extensions[0].value
    assert_equal "authorityKeyIdentifier", cert.extensions[1].oid
    assert_equal "F7:A9:D9:32:BC:FD:E6:C9:FB:3D:FF:3B:EE:89:5A:B4:D5:FD:71:61", cert.extensions[1].value
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
    assert_equal "AA:E6:D7:9F:75:79:58:24:4B:92:A5:BE:C4:C6:1F:41:EE:3B:EF:56", cert.extensions[0].value
    assert_equal "authorityKeyIdentifier", cert.extensions[1].oid
    assert_equal "DE:32:23:B1:86:68:FC:37:0E:61:3A:7B:5B:5F:CD:29:87:E3:B9:62", cert.extensions[1].value
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
