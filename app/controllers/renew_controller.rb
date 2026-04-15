class RenewController < ApplicationController
  before_action :set_certificate
  def show
  end

  def update
    ca_params = @certificate.is_root? ? nil : {
      :certificate => @parent,
      :key => @parent.key,
      :password => params[:authority_password]
    }

    new_certificate = Certificate.create({
      name: "/C=CA/ST=Quebec/L=Montreal/O=nu12/OU=cert-manager/CN=Root CA",
      expirity_months: 120
    }, {
      key: keys(:root),
      password: "cert-manager"
    }, ca_params)

    redirect_certificate new_certificate
  end
  private
    def renew_root
      @certificate = Certificate.create!(content: CertManager::Certificate.create_root(CertManager::Key.parse(@key, @password), "/C=#{@c}/ST=#{@st}/L=#{@l}/O=#{@o}/OU=#{@ou}/CN=#{@cn}", 0, @expirity_in_days), name: @cn, user: current_user, key: @key, expired_at: @expirity_date)
    end
    def renew_intermediate
      root_key = @parent.key
      @certificate = Certificate.create!(content: CertManager::Certificate.create_intermediate(CertManager::Key.parse(@key, @password), "/C=#{@c}/ST=#{@st}/L=#{@l}/O=#{@o}/OU=#{@ou}/CN=#{@cn}", CertManager::Certificate.parse(@parent), CertManager::Key.parse(root_key, @authority_password), 0, @expirity_in_days), name: @cn, user: current_user, key: @key, expired_at: @expirity_date, parent: @parent)
    end
    def renew_server
      root_key = @parent.key
      @key = @certificate.key
      @authority_password = params[:authority_password]
      @password = params[:password]
      @validity = params[:validity]
      @expirity_in_days = 30 * @validity.to_i
      @expirity_date = DateTime.now + @expirity_in_days.days
      @certificate = Certificate.create!(content: CertManager::Certificate.create_server(CertManager::Key.parse(@key, @password), CertManager::Certificate.parse(@certificate).subject.to_s, CertManager::Certificate.parse(@parent), CertManager::Key.parse(root_key, @authority_password), 0, @expirity_in_days), name: @certificate.name, user: current_user, key: @key, expired_at: @expirity_date, parent: @parent)
    end
    def set_certificate
      params.expect(:id)
      @certificate = Certificate.find(params[:id])
      authorize @certificate
      @parent = @certificate.parent
      authorize @parent, policy_class: CertificatePolicy unless @certificate.type == :root
    end
end
