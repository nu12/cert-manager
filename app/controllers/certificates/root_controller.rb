class Certificates::RootController < ApplicationController
  before_action :set_certificate, only: %i[ show ]
  def index
  end

  def show
  end

  def new
    @c, @st, @l, @o, @ou, @cn, @size, @password = ""
    @validity = "120"
  end


  private
    def set_certificate
      params.expect(:id)
      @certificate = Certificate.find(params[:id])
      authorize @certificate
      raise ArgumentError, "#{@certificate.name} is not a root certificate." unless @certificate.is_root?
    end
end
