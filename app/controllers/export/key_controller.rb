class Export::KeyController < ApplicationController
  def show
    params.expect(:serial)
    @certificate = Certificate.find_by(serial: params[:serial])
    authorize @certificate

    render plain: @certificate.key.pem, layout: false
  end
end
