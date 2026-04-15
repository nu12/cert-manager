require "openssl"

class CertManager::Key
  def self.create(size)
    content = OpenSSL::PKey::RSA.new size
    content.to_pem
  end

  def self.import(text, passphrase)
    priv = OpenSSL::PKey::RSA.new(text)
    priv.export(OpenSSL::Cipher.new("AES-128-CBC"), passphrase)
  end

  def self.parse(model)
    OpenSSL::PKey::RSA.new model.content
  end
end
