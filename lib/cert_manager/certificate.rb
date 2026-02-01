require "openssl"

class CertManager::Certificate
  def self.create_root(key, name, serial = 0, version = 0, expires_after_days = 3650)
    ca_name = OpenSSL::X509::Name.parse name
    ca_cert = OpenSSL::X509::Certificate.new
    ca_cert.serial = serial
    ca_cert.version = version
    ca_cert.not_before = Time.now
    ca_cert.not_after = Time.now + (expires_after_days * 24 * 60 * 60)

    ca_cert.public_key = key.public_key
    ca_cert.subject = ca_name
    ca_cert.issuer = ca_name

    extension_factory = OpenSSL::X509::ExtensionFactory.new
    extension_factory.subject_certificate = ca_cert
    extension_factory.issuer_certificate = ca_cert

    ca_cert.add_extension    extension_factory.create_extension("subjectKeyIdentifier", "hash")
    ca_cert.add_extension    extension_factory.create_extension("authorityKeyIdentifier", "keyid,issuer")
    ca_cert.add_extension    extension_factory.create_extension("basicConstraints", "CA:TRUE", true)
    ca_cert.add_extension    extension_factory.create_extension("keyUsage", "cRLSign,keyCertSign", true)

    # CA is self-signed
    ca_cert.sign key, OpenSSL::Digest::SHA256.new
    ca_cert.to_pem
  end

  def self.create_intermediate(key, name, root_cert, root_key, serial = 0, version = 0, expires_after_days = 1825)
    inter_name = OpenSSL::X509::Name.parse name

    # CSR
    # inter_csr = OpenSSL::X509::Request.new
    # inter_csr.version = version
    # inter_csr.subject = inter_name
    # inter_csr.public_key = inter_key.public_key
    # inter_csr.sign inter_key, OpenSSL::Digest::SHA256.new

    # Sign CSR
    inter_cert = OpenSSL::X509::Certificate.new
    inter_cert.serial = serial
    inter_cert.version = version
    inter_cert.not_before = Time.now
    inter_cert.not_after = Time.now + (expires_after_days * 24 * 60 * 60)

    inter_cert.subject = inter_name # inter_csr.subject
    inter_cert.public_key = key.public_key # inter_csr.public_key
    inter_cert.issuer = root_cert.subject

    extension_factory = OpenSSL::X509::ExtensionFactory.new
    extension_factory.subject_certificate = inter_cert
    extension_factory.issuer_certificate = root_cert

    inter_cert.add_extension    extension_factory.create_extension("subjectKeyIdentifier", "hash")
    inter_cert.add_extension    extension_factory.create_extension("authorityKeyIdentifier", "keyid,issuer")
    inter_cert.add_extension    extension_factory.create_extension("basicConstraints", "CA:TRUE,pathlen:0", true)
    inter_cert.add_extension    extension_factory.create_extension("keyUsage", "digitalSignature,cRLSign,keyCertSign", true)

    inter_cert.sign root_key, OpenSSL::Digest::SHA256.new
    inter_cert.to_pem
  end
  def self.create_server(key, name, inter_cert, inter_key, serial = 0, version = 0, expires_after_days = 365)
    server_name = OpenSSL::X509::Name.parse name

    # CSR
    # server_csr = OpenSSL::X509::Request.new
    # server_csr.version = version
    # server_csr.subject = server_name
    # server_csr.public_key = server_key.public_key
    # server_csr.sign server_key, OpenSSL::Digest::SHA256.new

    # Sign CSR
    server_cert = OpenSSL::X509::Certificate.new
    server_cert.serial = serial
    server_cert.version = version
    server_cert.not_before = Time.now
    server_cert.not_after = Time.now + (expires_after_days * 24 * 60 * 60) # 1 year in seconds

    server_cert.subject = server_name # server_csr.subject
    server_cert.public_key = key.public_key # server_csr.public_key
    server_cert.issuer = inter_cert.subject

    extension_factory = OpenSSL::X509::ExtensionFactory.new
    extension_factory.subject_certificate = server_cert
    extension_factory.issuer_certificate = inter_cert

    server_cert.add_extension    extension_factory.create_extension("subjectKeyIdentifier", "hash")
    server_cert.add_extension    extension_factory.create_extension("authorityKeyIdentifier", "keyid,issuer")
    server_cert.add_extension    extension_factory.create_extension("basicConstraints", "CA:FALSE")
    server_cert.add_extension    extension_factory.create_extension("keyUsage", "keyEncipherment,digitalSignature", true)
    server_cert.add_extension    extension_factory.create_extension("extendedKeyUsage", "serverAuth")

    server_cert.sign inter_key, OpenSSL::Digest::SHA256.new
    server_cert.to_pem
  end

  def self.import(text)
    OpenSSL::X509::Certificate.new(text).to_pem
  end

  def self.parse(model)
    OpenSSL::X509::Certificate.new model.content
  end
end
