class RenewController < ApplicationController
  before_action :set_certificate
  def show
  end

  def update
    renew_root if @certificate.type == :root
    renew_intermediate if @certificate.type == :intermediate
    renew_server if @certificate.type == :server

    redirect_to certificates_root_intermediate_server_path(@parent.parent, @parent, @certificate), notice: "Server certificate was successfully created."
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
