class Certificates::RootController < ApplicationController
  before_action :set_certificate, only: %i[ show ]
  def index
  end

  def show
    @root_certificate = @certificate
    render "certificates/show"
  end

  def new
    @certificate = Certificate.new
  end


  private
    def set_certificate
      params.expect(:serial)
      @certificate = Certificate.find_by(serial: params[:serial])
      authorize @certificate
      raise ArgumentError, "#{@certificate.common_name} is not a root certificate." unless @certificate.is_root?
    end
end
