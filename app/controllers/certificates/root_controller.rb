class Certificates::RootController < ApplicationController
  def index
  end

  def show
    @certificate = Certificate.find(params[:id])
  end

  def new
    @certificate = Certificate.new
  end

  def create
    params.expect([ :country, :state, :location, :organization, :organization_unit, :common_name, :key_size ])
    begin
      key = Key.create!(content: CertManager::Key.create(params[:key_size].to_i, params[:password]), user: current_user)
      certificate = Certificate.create!(content: CertManager::Certificate.create_root(CertManager::Key.parse(key, params[:password]), "/C=#{params[:country]}/ST=#{params[:state]}/L=#{params[:location]}/O=#{params[:organization]}/OU=#{params[:organization_unit]}/CN=#{params[:common_name]}"), name: params[:common_name], user: current_user, key: key)
      redirect_to certificates_root_path(certificate), notice: "Certificate was successfully created."
    rescue => error
      @error = error.message
      render :new, status: :unprocessable_entity
    end
  end
end
