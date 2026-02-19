class Certificates::ServerController < ApplicationController
  def show
    @root_certificate = Certificate.find(params[:root_id])
    @intermediate_certificate = Certificate.find(params[:intermediate_id])
    @certificate = Certificate.find(params[:id])
  end
end
