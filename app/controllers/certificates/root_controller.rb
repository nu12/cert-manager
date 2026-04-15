class Certificates::RootController < ApplicationController
  before_action :set_certificate, only: %i[ show ]
  def index
  end

  def show
  end

  def new
    @certificate = Certificate.new
  end


  private
    def set_certificate
      params.expect(:id)
      @certificate = Certificate.find(params[:id])
      authorize @certificate
      raise ArgumentError, "#{@certificate.common_name} is not a root certificate." unless @certificate.is_root?
    end
end
