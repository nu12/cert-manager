class CertificatesController < ApplicationController
  before_action :certificate_params, only: %i[ create ]
  def create
    set_variables
    begin
      create_key_and_certificate
      redirect_certificate
    rescue => error
      @error = error.message
      render_form
    end
  end
  private
    def certificate_params
      params.expect([ :country, :state, :location, :organization, :organization_unit, :common_name, :key_size, :validity ])
      @authority_id = params[:authority_id]
      @c = params[:country]
      @st = params[:state]
      @l = params[:location]
      @o = params[:organization]
      @ou = params[:organization_unit]
      @cn = params[:common_name]
      @size = params[:key_size]
      @validity = params[:validity]
    end
    def set_variables
      @parent = Certificate.find_by(id: @authority_id)
      authorize @parent, policy_class: CertificatePolicy if @parent

      @expirity_in_days = 30 * @validity.to_i
      @expirity_date = DateTime.now + @expirity_in_days.days
    end
    def create_key_and_certificate
      @key = Key.create!(content: CertManager::Key.create(@size.to_i), user: current_user)
      return create_root unless @parent
      return create_intermediate if @parent.is_root?
      create_server
    end
    def create_root
      @certificate = Certificate.create!(content: CertManager::Certificate.create_root(CertManager::Key.parse(@key), "/C=#{@c}/ST=#{@st}/L=#{@l}/O=#{@o}/OU=#{@ou}/CN=#{@cn}", 0, @expirity_in_days), name: @cn, user: current_user, key: @key, expired_at: @expirity_date)
    end
    def create_intermediate
      root_key = @parent.key
      @certificate = Certificate.create!(content: CertManager::Certificate.create_intermediate(CertManager::Key.parse(@key), "/C=#{@c}/ST=#{@st}/L=#{@l}/O=#{@o}/OU=#{@ou}/CN=#{@cn}", CertManager::Certificate.parse(@parent), CertManager::Key.parse(root_key), 0, @expirity_in_days), name: @cn, user: current_user, key: @key, expired_at: @expirity_date, parent: @parent)
    end
    def create_server
      root_key = @parent.key
      @certificate = Certificate.create!(content: CertManager::Certificate.create_server(CertManager::Key.parse(@key), "/C=#{@c}/ST=#{@st}/L=#{@l}/O=#{@o}/OU=#{@ou}/CN=#{@cn}", CertManager::Certificate.parse(@parent), CertManager::Key.parse(root_key), 0, @expirity_in_days), name: @cn, user: current_user, key: @key, expired_at: @expirity_date, parent: @parent)
    end
    def redirect_certificate
      if @certificate.is_root?
        redirect_to certificates_root_path(@certificate), notice: "Root certificate was successfully created."
        return
      end

      if @certificate.is_intermediate?
        redirect_to certificates_root_intermediate_path(@parent, @certificate), notice: "Intermediate certificate was successfully created."
        return
      end
      redirect_to certificates_root_intermediate_server_path(@parent.parent, @parent, @certificate), notice: "Server certificate was successfully created."
    end
    def render_form
      unless @parent
        render "certificates/root/new", status: :unprocessable_entity
        return
      end

      if @parent.is_root?
        render "certificates/intermediate/new", status: :unprocessable_entity
        return
      end
      render "certificates/server/new", status: :unprocessable_entity
    end
end
