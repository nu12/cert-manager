class Certificates::ServerController < ApplicationController
  before_action :set_certificates, only: %i[ show ]
  def show
  end
  def new
    @parent = Certificate.find(params[:intermediate_id])
    @c, @st, @l, @o, @ou, @cn, @size, @password = ""
    @validity = "12"
  end
  
  private
    def set_certificates
      @certificate = Certificate.find(params[:id])
      authorize @certificate
      raise ArgumentError, "#{@certificate.name} is not a server certificate." unless @certificate.is_server?
      @intermediate_certificate = @certificate.parent
      @root_certificate = @intermediate_certificate.parent
    end
end
