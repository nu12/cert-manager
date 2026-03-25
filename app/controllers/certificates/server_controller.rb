class Certificates::ServerController < ApplicationController
  before_action :set_certificates, only: %i[ show ]
  before_action :certificate_params, only: %i[ create ]
  def show
  end
  def new
    @parent = Certificate.find(params[:intermediate_id])
    @c, @st, @l, @o, @ou, @cn, @size, @password = ""
    @validity = "12"
  end
  def create
    @parent = Certificate.find(params[:intermediate_id])
    expirity_in_days = 30 * @validity.to_i
    expirity_date = DateTime.now + expirity_in_days.days
    begin
      root_key = @parent.key
      key = Key.create!(content: CertManager::Key.create(@size.to_i, @password), user: current_user)
      certificate = Certificate.create!(content: CertManager::Certificate.create_intermediate(CertManager::Key.parse(key, @password), "/C=#{@c}/ST=#{@st}/L=#{@l}/O=#{@o}/OU=#{@ou}/CN=#{@cn}", CertManager::Certificate.parse(@parent), CertManager::Key.parse(root_key, @authority_password), 0, expirity_in_days), name: @cn, user: current_user, key: key, expired_at: expirity_date, parent: @parent)
      redirect_to certificates_root_intermediate_server_path(@parent.parent, @parent, certificate), notice: "Certificate was successfully created."
    rescue => error
      @error = error.message
      render :new, status: :unprocessable_entity
    end
  end
  private
    def set_certificates
      @certificate = Certificate.find(params[:id])
      authorize @certificate
      raise ArgumentError, "#{@certificate.name} is not a server certificate." unless @certificate.is_server?
      @intermediate_certificate = @certificate.parent
      @root_certificate = @intermediate_certificate.parent
    end
end
