class CertificatesController < ApplicationController
  def create
    @certificate = Certificate.new(certificate_params)

    if @certificate.save
      redirect_certificate @certificate
    else
      render "forms/certificate", status: :unprocessable_entity
    end
  end
  private
    def certificate_params
      parent = Certificate.find_by(id: params[:certificate][:certificate_id])
      authorize parent, policy_class: CertificatePolicy if parent
      cert = params.expect(certificate: [ :country, :state, :location, :organization, :organization_unit, :common_name, :expirity_date, :certificate_id ])
      cert.merge!({ user: current_user, key: Key.create!(user: current_user) })
    end
end
