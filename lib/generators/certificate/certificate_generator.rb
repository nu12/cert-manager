require "fileutils"
require "io/console"

class CertificateGenerator < Rails::Generators::Base
  class_option :country, desc: "Country (two-letter abbreviation)", type: :string, required: true
  class_option :state, desc: "State", type: :string, required: true
  class_option :location, desc: "Location", type: :string, required: true
  class_option :organization, desc: "Organization", type: :string, required: true
  class_option :organization_unit, desc: "Organization Unit", type: :string, required: true
  class_option :common_name, desc: "FQDN of the certificate", type: :string, required: true
  source_root File.expand_path("templates", __dir__)

  def setup
    @c = options["country"]
    @s = options["state"]
    @l = options["location"]
    @o = options["organization"]
    @u = options["organization_unit"]
    @n = options["common_name"]
    @name = "/C=#{@c}/ST=#{@s}/L=#{@l}/O=#{@o}/OU=#{@u}/CN=#{@n}"
  end

  def create_certificates
    FileUtils.mkdir_p "#{destination_root}/storage/#{@n}/root"
    FileUtils.mkdir_p "#{destination_root}/storage/#{@n}/intermediate"
    FileUtils.mkdir_p "#{destination_root}/storage/#{@n}/server"

    root_key = OpenSSL::PKey::RSA.new(4096)
    root_cert = OpenSSL::X509::Certificate.new(CertManager::Certificate.create_root(root_key, "#{@name} (Root)"))
    open("#{destination_root}/storage/#{@n}/root/key.pem", "w") { |io| io.write(root_key.private_to_pem)  }
    open("#{destination_root}/storage/#{@n}/root/cert.pem", "w") { |io| io.write(root_cert.to_pem)  }

    intermediate_key = OpenSSL::PKey::RSA.new(4096)
    intermediate_cert = OpenSSL::X509::Certificate.new(CertManager::Certificate.create_intermediate(intermediate_key, "#{@name} (Intermediate)", root_cert, root_key))
    open("#{destination_root}/storage/#{@n}/intermediate/key.pem", "w") { |io| io.write(intermediate_key.private_to_pem)  }
    open("#{destination_root}/storage/#{@n}/intermediate/cert.pem", "w") { |io| io.write(intermediate_cert.to_pem)  }

    server_key = OpenSSL::PKey::RSA.new(4096)
    server_cert = OpenSSL::X509::Certificate.new(CertManager::Certificate.create_server(server_key, "#{@name}", intermediate_cert, intermediate_key))
    open("#{destination_root}/storage/#{@n}/server/key.pem", "w") { |io| io.write(server_key.private_to_pem)  }
    open("#{destination_root}/storage/#{@n}/server/cert.pem", "w") { |io| io.write(server_cert.to_pem)  }

    open "#{destination_root}/storage/#{@n}/server/chain.pem", "w" do |io|
      io.write intermediate_cert.to_pem
      io.write root_cert.to_pem
    end
  end
end
