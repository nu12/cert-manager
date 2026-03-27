class DeleteController < ApplicationController
  before_action :set_certificate
  def show
  end

  def destroy
    if @certificate.destroy!
      @certificate.key.destroy! if @certificate.key.certificates.count == 0
      redirect_to root_path, notice: "Certificate was successfully deleted.", status: :see_other
    else
      redirect_to delete_path(@certificate), alert: "Certificate cannot be deleted.", status: :see_other
    end
  end
  private
    def set_certificate
      params.expect(:id)
      @certificate = Certificate.find(params[:id])
      authorize @certificate
    end
end
