class Certificate < ApplicationRecord
  belongs_to :user
  belongs_to :key
  belongs_to :certificate, optional: true
  has_many :children, class_name: "Certificate", foreign_key: "certificate_id"
  belongs_to :parent, class_name: "Certificate", foreign_key: "certificate_id", optional: true

  def is_valid?
    self.expired_at >= DateTime.now
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

  def self.create(cert_params, key_params, ca_params = nil)
    expirity_in_days = 30 * cert_params[:expirity_months]
    expirity_date = DateTime.now + expirity_in_days.days
    key = CertManager::Key.parse(key_params[:key])
    return create!(content: CertManager::Certificate.create_root(key, cert_params[:name], 0, expirity_in_days), name: cert_params[:name].match(/CN=(.*)/)[1], user: key_params[:key].user, key: key_params[:key], expired_at: expirity_date) unless ca_params

    parent_key = CertManager::Key.parse(ca_params[:key])
    parent_certificate = CertManager::Certificate.parse(ca_params[:certificate])
    return create!(content: CertManager::Certificate.create_intermediate(key, cert_params[:name], parent_certificate, parent_key, 0, expirity_in_days), name: cert_params[:name].match(/CN=(.*)/)[1], user: key_params[:key].user, key: key_params[:key], expired_at: expirity_date, parent: ca_params[:certificate]) if ca_params[:certificate].is_root?
    create!(content: CertManager::Certificate.create_server(key, cert_params[:name], parent_certificate, parent_key, 0, expirity_in_days), name: cert_params[:name].match(/CN=(.*)/)[1], user: key_params[:key].user, key: key_params[:key], expired_at: expirity_date, parent: ca_params[:certificate]) if ca_params[:certificate].is_intermediate?
  end
end
