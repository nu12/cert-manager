require "fileutils"
require 'io/console'

class GeneratorKey
  attr_accessor(:content)
  def write path
    open path, "w" do |io|
      io.write @content.private_to_pem
    end
  end
end

class GeneratorCertificate
  attr_accessor(:content)
  def write path
    open path, "w" do |io|
      io.write @content.to_pem
    end
  end
end

class CertificateGenerator < Rails::Generators::Base
  class_option :country, desc: "Country (two-letter abbreviation)", type: :string, required: true
  class_option :state, desc: "State", type: :string, required: true
  class_option :location, desc: "Location", type: :string, required: true
  class_option :organization, desc: "Organization", type: :string, required: true
  class_option :organization_unit, desc: "Organization Unit", type: :string, required: true
  class_option :common_name, desc: "FQDN of the certificate", type: :string, required: true
  class_option :key_passphrase, desc: "Passphrase to be used for the RSA key generation", type: :string, required: false
  source_root File.expand_path("templates", __dir__)

  def setup
    @c = options["country"]
    @s = options["state"]
    @l = options["location"]
    @o = options["organization"]
    @u = options["organization_unit"]
    @n = options["common_name"]
    @name = "/C=#{@c}/ST=#{@s}/L=#{@l}/O=#{@o}/OU=#{@u}/CN=#{@n}"
    if options["key_passphrase"]
      @pw = options["key_passphrase"]
    else
      print "Enter key password: "
      @pw = STDIN.noecho(&:gets).chomp
    end

  end

  def create_certificates
    FileUtils.mkdir_p "#{destination_root}/storage/#{@n}/root"
    FileUtils.mkdir_p "#{destination_root}/storage/#{@n}/intermediate"
    FileUtils.mkdir_p "#{destination_root}/storage/#{@n}/server"

    root_key = GeneratorKey.new
    root_key.content = OpenSSL::PKey::RSA.new(CertManager::Key.create(4096, @pw), @pw)
    root_key.write("#{destination_root}/storage/#{@n}/root/key.pem")
    root_cert = GeneratorCertificate.new
    root_cert.content = OpenSSL::X509::Certificate.new(CertManager::Certificate.create_root(root_key, "#{@name} (Root)"))
    root_cert.write("#{destination_root}/storage/#{@n}/root/cert.pem")

    intermediate_key = GeneratorKey.new
    intermediate_key.content = OpenSSL::PKey::RSA.new(CertManager::Key.create(4096, @pw), @pw)
    intermediate_key.write("#{destination_root}/storage/#{@n}/intermediate/key.pem")
    intermediate_cert = GeneratorCertificate.new
    intermediate_cert.content = OpenSSL::X509::Certificate.new(CertManager::Certificate.create_intermediate(intermediate_key, "#{@name} (Intermediate)", root_cert, root_key))
    intermediate_cert.write("#{destination_root}/storage/#{@n}/intermediate/cert.pem")
    
    server_key = GeneratorKey.new
    server_key.content = OpenSSL::PKey::RSA.new(CertManager::Key.create(4096, @pw), @pw)
    server_key.write("#{destination_root}/storage/#{@n}/server/key.pem")
    server_cert = GeneratorCertificate.new
    server_cert.content = OpenSSL::X509::Certificate.new(CertManager::Certificate.create_server(server_key, "#{@name}", intermediate_cert, intermediate_key))
    server_cert.write("#{destination_root}/storage/#{@n}/server/cert.pem")
    
    open "#{destination_root}/storage/#{@n}/server/chain.pem", "w" do |io|
      io.write intermediate_cert.content.to_pem
      io.write root_cert.content.to_pem
    end
  end
end
