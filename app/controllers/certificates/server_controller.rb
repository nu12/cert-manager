class Certificates::ServerController < ApplicationController
  before_action :set_certificates, only: %i[ show ]
  before_action :validate_parents
  def show
  end
  def new
    @certificate = Certificate.new(certificate_id: @intermediate_certificate.id)
  end

  private
    def set_certificates
      params.expect(:serial, :root_serial, :intermediate_serial)
      @certificate = Certificate.find_by(serial: params[:serial])
      authorize @certificate
      raise ArgumentError, "#{@certificate.common_name} is not a server certificate." unless @certificate.is_server?
    end
    def validate_parents
      @intermediate_certificate = Certificate.find_by(serial: params[:intermediate_serial])
      authorize @intermediate_certificate, policy_class: CertificatePolicy
      raise ArgumentError, "#{@intermediate_certificate.common_name} is not a intermediate certificate." unless @intermediate_certificate.is_intermediate?
      @root_certificate = Certificate.find_by(serial: params[:root_serial])
      authorize @root_certificate, policy_class: CertificatePolicy
      raise ArgumentError, "#{@root_certificate.common_name} is not a root certificate." unless @root_certificate.is_root?
    end
end
