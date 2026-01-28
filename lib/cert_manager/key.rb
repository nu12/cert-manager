require "openssl"

class CertManager::Key
  attr_accessor(:content)

  def self.create(size, passphrase)
    content = OpenSSL::PKey::RSA.new size
    content.export(OpenSSL::Cipher.new("AES-128-CBC"), passphrase)
  end

  def self.import(text, passphrase)
    priv = OpenSSL::PKey::RSA.new(text)
    priv.export(OpenSSL::Cipher.new("AES-128-CBC"), passphrase)
  end

  def self.parse(model, passphrase)
    obj = allocate
    obj.content = OpenSSL::PKey::RSA.new model.content, passphrase
    obj
  end
end
