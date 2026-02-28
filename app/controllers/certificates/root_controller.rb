require "date"

class Certificates::RootController < ApplicationController
  before_action :set_certificate, only: %i[ show ]
  before_action :certificate_params, only: %i[ create ]
  def index
  end

  def show
  end

  def new
    @c, @st, @l, @o, @ou, @cn, @size, @password = ""
    @validity = "120"
  end

  def create
    expirity_in_days = 30 * @validity.to_i
    expirity_date = DateTime.now + expirity_in_days.days
    begin
      key = Key.create!(content: CertManager::Key.create(@size.to_i, @password), user: current_user)
      certificate = Certificate.create!(content: CertManager::Certificate.create_root(CertManager::Key.parse(key, @password), "/C=#{@c}/ST=#{@st}/L=#{@l}/O=#{@o}/OU=#{@ou}/CN=#{@cn}", 0, 0, expirity_in_days), name: @cn, user: current_user, key: key, expired_at: expirity_date)
      redirect_to certificates_root_path(certificate), notice: "Certificate was successfully created."
    rescue => error
      @error = error.message
      render :new, status: :unprocessable_entity
    end
  end
  private
    def set_certificate
      params.expect(:id)
      @certificate = Certificate.find(params[:id])
      # authorize @certificate
    end
    def certificate_params
      params.expect([ :country, :state, :location, :organization, :organization_unit, :common_name, :key_size, :validity ])
      @c = params[:country]
      @st = params[:state]
      @l = params[:location]
      @o = params[:organization]
      @ou = params[:organization_unit]
      @cn = params[:common_name]
      @size = params[:key_size]
      @password = params[:password]
      @validity = params[:validity]
    end
end
