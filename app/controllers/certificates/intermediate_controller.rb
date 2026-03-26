class Certificates::IntermediateController < ApplicationController
  before_action :set_certificates, only: %i[ show ]
  def show
  end
  def new
    @parent = Certificate.find(params[:root_id])
    @c, @st, @l, @o, @ou, @cn, @size, @password = ""
    @validity = "60"
  end
  private
    def set_certificates
      @certificate = Certificate.find(params[:id])
      authorize @certificate
      raise ArgumentError, "#{@certificate.name} is not an intermediate certificate." unless @certificate.is_intermediate?
      @root_certificate = @certificate.parent
    end
end
