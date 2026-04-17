class DeleteController < ApplicationController
  before_action :set_certificate
  def show
  end

  def destroy
    if @certificate.destroy!
      @certificate.key.destroy! if @certificate.key.certificates.count == 0
      redirect_certificate(@certificate.parent, "Certificate was successfully deleted.")
    else
      redirect_to delete_path(@certificate.serial), alert: "Certificate cannot be deleted.", status: :see_other
    end
  end
  private
    def set_certificate
      params.expect(:serial)
      @certificate = Certificate.find_by(serial: params[:serial])
      authorize @certificate
    end
end
