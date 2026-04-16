class RenewController < ApplicationController
  def show
    @certificate = Certificate.find(params[:id])
    authorize @certificate
  end

  def update
    params.expect([ :id, :expirity_date ])
    @certificate = Certificate.find(params[:id])
    authorize @certificate

    new_certificate = Certificate.new(
      country: @certificate.country,
      state: @certificate.state,
      location: @certificate.location,
      organization: @certificate.organization,
      organization_unit: @certificate.organization_unit,
      common_name: @certificate.common_name,
      user: current_user,
      key: @certificate.key,
      parent: @certificate.parent,
      expirity_date: params[:expirity_date]
    )

    if new_certificate.save
      redirect_certificate new_certificate
    else
      render "forms/certificate", status: :unprocessable_entity
    end
  end
end
