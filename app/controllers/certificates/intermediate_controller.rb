class Certificates::IntermediateController < ApplicationController
  def show
    @root_certificate = Certificate.find(params[:root_id])
    @certificate = Certificate.find(params[:id])
  end
end
