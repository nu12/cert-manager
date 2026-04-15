class Certificate < ApplicationRecord
  belongs_to :user
  belongs_to :key
  belongs_to :certificate, optional: true
  has_many :children, class_name: "Certificate", foreign_key: "certificate_id"
  belongs_to :parent, class_name: "Certificate", foreign_key: "certificate_id", optional: true

  after_create :set_content

  def is_valid?
    self.expirity_date >= DateTime.now
  end

  def is_root?
    self.parent.nil?
  end

  def is_intermediate?
    return false if self.parent.nil?
    self.parent.is_root?
  end
  def is_server?
    return false if self.parent.nil?
    self.parent.is_intermediate?
  end
  def destroy!
    return false if self.children.count != 0
    super
  end
  def type
    return :root if is_root?
    return :intermediate if is_intermediate?
    return :server if is_server?
  end

  # def self.create(cert_params, key_params, ca_params = nil)
  #   expirity_in_days = Date.parse(cert_params[:expirity_date]) - DateTime.now
  #   key = CertManager::Key.parse(key_params[:key])
  #   return create!(content: CertManager::Certificate.create_root(key, cert_params[:name], 0, expirity_in_days), name: cert_params[:name].match(/CN=(.*)/)[1], user: key_params[:key].user, key: key_params[:key], expirity_date: cert_params[:expirity_date]) unless ca_params

  #   parent_key = CertManager::Key.parse(ca_params[:key])
  #   parent_certificate = CertManager::Certificate.parse(ca_params[:certificate])
  #   return create!(content: CertManager::Certificate.create_intermediate(key, cert_params[:name], parent_certificate, parent_key, 0, expirity_in_days), name: cert_params[:name].match(/CN=(.*)/)[1], user: key_params[:key].user, key: key_params[:key], expirity_date: cert_params[:expirity_date], parent: ca_params[:certificate]) if ca_params[:certificate].is_root?
  #   create!(content: CertManager::Certificate.create_server(key, cert_params[:name], parent_certificate, parent_key, 0, expirity_in_days), name: cert_params[:name].match(/CN=(.*)/)[1], user: key_params[:key].user, key: key_params[:key], expirity_date: cert_params[:expirity_date], parent: ca_params[:certificate]) if ca_params[:certificate].is_intermediate?
  # end

  private
    def set_content
      expirity_in_days = self.expirity_date - DateTime.now
      self.name = "/C=#{self.country}/ST=#{self.state}/L=#{self.location}/O=#{self.organization}/OU=#{self.organization_unit}/CN=#{self.common_name}"
      if self.is_root?
        self.content = CertManager::Certificate.create_root(CertManager::Key.parse(self.key), self.name, 0, expirity_in_days)
      end
      if self.is_intermediate?
        self.content = CertManager::Certificate.create_intermediate(CertManager::Key.parse(self.key), self.name, CertManager::Certificate.parse(self.parent), CertManager::Key.parse(self.parent.key), 0, expirity_in_days)
      end
      if self.is_server?
        self.content = CertManager::Certificate.create_server(CertManager::Key.parse(self.key), self.name, CertManager::Certificate.parse(self.parent), CertManager::Key.parse(self.parent.key), 0, expirity_in_days)
      end
      self.save
    end
end
