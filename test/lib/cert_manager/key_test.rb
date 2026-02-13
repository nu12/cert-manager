require "test_helper"
require "cert_manager/key"

class CertManagerKeyTest < ActionDispatch::IntegrationTest
  test "methods" do
    assert CertManager::Key.respond_to? :create
    assert CertManager::Key.respond_to? :import
    assert CertManager::Key.respond_to? :parse
  end

  test "create" do
    key = CertManager::Key.create(512, "cert-manager")
    assert key.include? "-----BEGIN RSA PRIVATE KEY-----\nProc-Type: 4,ENCRYPTED"
  end

  test "import" do
    key = CertManager::Key.import(File.read("test/fixtures/files/private_key.pem"), "cert-manager")
    assert key.include? "-----BEGIN RSA PRIVATE KEY-----\nProc-Type: 4,ENCRYPTED"
  end

  test "parse" do
    key = CertManager::Key.parse(keys(:root), "cert-manager")
    assert key.respond_to? :public_to_pem
    assert key.respond_to? :private_to_pem
  end
end
