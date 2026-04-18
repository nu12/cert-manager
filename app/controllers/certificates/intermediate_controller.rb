class Certificates::IntermediateController < ApplicationController
  before_action :set_certificates, only: %i[ show ]
  before_action :validate_parents
  def show
    @intermediate_certificate = @certificate
    render "certificates/show"
  end
  def new
    @certificate = Certificate.new(certificate_id: @root_certificate.id)
  end
  private
    def set_certificates
      params.expect(:serial, :root_serial)
      @certificate = Certificate.find_by(serial: params[:serial])
      authorize @certificate
      raise ArgumentError, "#{@certificate.common_name} is not an intermediate certificate." unless @certificate.is_intermediate?
    end
    def validate_parents
      @root_certificate = Certificate.find_by(serial: params[:root_serial])
      authorize @root_certificate, policy_class: CertificatePolicy
      raise ArgumentError, "#{@root_certificate.common_name} is not a root certificate." unless @root_certificate.is_root?
    end
end
