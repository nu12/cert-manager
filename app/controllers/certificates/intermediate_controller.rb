class Certificates::IntermediateController < ApplicationController
  before_action :set_certificates, only: %i[ show ]
  def show
  end
  private
    def set_certificates
      @certificate = Certificate.find(params[:id])
      authorize @certificate
      raise ArgumentError, "#{@certificate.name} is not an intermediate certificate." unless @certificate.is_intermediate?
      @root_certificate = @certificate.parent
    end
end
