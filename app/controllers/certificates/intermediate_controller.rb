class Certificates::IntermediateController < ApplicationController
  def show
    @certificate = Certificate.find(params[:id])
    authorize @certificate
    @root_certificate = @certificate.parent
  end
end
