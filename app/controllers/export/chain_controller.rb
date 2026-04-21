class Export::ChainController < ApplicationController
  def show
    params.expect(:serial)
    @certificate = Certificate.find_by(serial: params[:serial])
    authorize @certificate
    raise ArgumentError, "#{@certificate.common_name} is not an intermediate certificate." unless @certificate.is_intermediate?

    render plain: "#{@certificate.pem}#{@certificate.parent.pem}", layout: false
  end
end
