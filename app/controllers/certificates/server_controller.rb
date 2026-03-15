class Certificates::ServerController < ApplicationController
  def show
    @certificate = Certificate.find(params[:id])
    authorize @certificate
    @intermediate_certificate = @certificate.parent
    @root_certificate = @intermediate_certificate.parent
  end
end
