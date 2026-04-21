class Export::PfxController < ApplicationController
  def create
    params.expect(:serial, :password)
    @certificate = Certificate.find_by(serial: params[:serial])
    authorize @certificate
    raise ArgumentError, "#{@certificate.common_name} is not a server certificate." unless @certificate.is_server?

    pfx = OpenSSL::PKCS12.create(params[:password], @certificate.common_name, CertManager::Key.parse(@certificate.key), CertManager::Certificate.parse(@certificate))
    render plain: pfx.to_der, layout: false
  end
end
