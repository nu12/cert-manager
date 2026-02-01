require "openssl"

class CertManager::Key
  def self.create(size, passphrase)
    content = OpenSSL::PKey::RSA.new size
    content.export(OpenSSL::Cipher.new("AES-128-CBC"), passphrase)
  end

  def self.import(text, passphrase)
    priv = OpenSSL::PKey::RSA.new(text)
    priv.export(OpenSSL::Cipher.new("AES-128-CBC"), passphrase)
  end

  def self.parse(model, passphrase)
    OpenSSL::PKey::RSA.new model.content, passphrase
  end
end
