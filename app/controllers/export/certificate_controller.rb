class Export::CertificateController < ApplicationController
  def show
    params.expect(:serial)
    @certificate = Certificate.find_by(serial: params[:serial])
    authorize @certificate

    render plain: @certificate.pem, layout: false
  end
end
