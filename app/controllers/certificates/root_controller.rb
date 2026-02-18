class Certificates::RootController < ApplicationController
  def index
  end

  def show
    @certificate = Certificate.find(params[:id])
  end
end
