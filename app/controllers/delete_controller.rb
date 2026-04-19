class DeleteController < ApplicationController
  before_action :set_certificate
  def destroy
    if @certificate.destroy!
      @certificate.key.destroy! if @certificate.key.certificates.count == 0
      redirect_certificate(@certificate.parent, { notice: "Certificate was successfully deleted.", status: :see_other })
    else
      redirect_certificate(@certificate, { alert: "Certificate cannot be deleted.", status: :see_other })
    end
  end
  private
    def set_certificate
      params.expect(:serial)
      @certificate = Certificate.find_by(serial: params[:serial])
      authorize @certificate
    end
end
