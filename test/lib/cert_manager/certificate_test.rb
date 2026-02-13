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
    key = CertManager::Key.parse(keys(:root), "cert-manager")
    raw = CertManager::Certificate.create_root(key, "/C=CA/ST=Quebec/L=Montreal/O=nu12/OU=cert-manager/CN=Root CA")
    assert raw.include? "-----BEGIN CERTIFICATE-----\n"

    cert = OpenSSL::X509::Certificate.new raw
    assert_equal 4, cert.extensions.size
    assert_equal "subjectKeyIdentifier", cert.extensions[0].oid
    assert_equal "BE:E2:A0:49:49:50:6B:3B:C8:04:BA:7F:DC:62:4D:8A:DC:F0:E1:ED", cert.extensions[0].value
    assert_equal "authorityKeyIdentifier", cert.extensions[1].oid
    assert_equal "BE:E2:A0:49:49:50:6B:3B:C8:04:BA:7F:DC:62:4D:8A:DC:F0:E1:ED", cert.extensions[1].value
    assert_equal "basicConstraints", cert.extensions[2].oid
    assert_equal "CA:TRUE", cert.extensions[2].value
    assert_equal "keyUsage", cert.extensions[3].oid
    assert_equal "Certificate Sign, CRL Sign", cert.extensions[3].value
    assert_equal OpenSSL::X509::Name, cert.subject.class
  end

  test "create_intermediate" do
    key = CertManager::Key.parse(keys(:intermediate), "cert-manager")
    root_cert = CertManager::Certificate.parse(certificates(:root))
    root_key = CertManager::Key.parse(certificates(:root).key, "cert-manager")
    raw = CertManager::Certificate.create_intermediate(key, "/C=CA/ST=Quebec/L=Montreal/O=nu12/OU=cert-manager/CN=Intermediate CA", root_cert, root_key)
    assert raw.include? "-----BEGIN CERTIFICATE-----\n"

    cert = OpenSSL::X509::Certificate.new raw
    assert_equal 4, cert.extensions.size
    assert_equal "subjectKeyIdentifier", cert.extensions[0].oid
    assert_equal "DE:32:23:B1:86:68:FC:37:0E:61:3A:7B:5B:5F:CD:29:87:E3:B9:62", cert.extensions[0].value
    assert_equal "authorityKeyIdentifier", cert.extensions[1].oid
    assert_equal "BE:E2:A0:49:49:50:6B:3B:C8:04:BA:7F:DC:62:4D:8A:DC:F0:E1:ED", cert.extensions[1].value
    assert_equal "basicConstraints", cert.extensions[2].oid
    assert_equal "CA:TRUE, pathlen:0", cert.extensions[2].value
    assert_equal "keyUsage", cert.extensions[3].oid
    assert_equal "Digital Signature, Certificate Sign, CRL Sign", cert.extensions[3].value
    assert_equal OpenSSL::X509::Name, cert.subject.class
  end

  test "create_server" do
    key = CertManager::Key.parse(keys(:server), "cert-manager")
    inter_cert = CertManager::Certificate.parse(certificates(:intermediate))
    inter_key = CertManager::Key.parse(certificates(:intermediate).key, "cert-manager")
    raw = CertManager::Certificate.create_server(key, "/C=CA/ST=Quebec/L=Montreal/O=nu12/OU=cert-manager/CN=cert-manager.github.nu12", inter_cert, inter_key)
    assert raw.include? "-----BEGIN CERTIFICATE-----\n"

    cert = OpenSSL::X509::Certificate.new raw
    assert_equal 5, cert.extensions.size
    assert_equal "subjectKeyIdentifier", cert.extensions[0].oid
    assert_equal "E4:85:74:DF:96:29:7F:4C:2E:62:94:53:BD:F1:12:BB:76:46:9C:FC", cert.extensions[0].value
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
