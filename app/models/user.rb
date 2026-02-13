class User < ApplicationRecord
  include Yaag::PasswordlessLogin

  has_many :certificates

  def root_certificates
    certificates.where(certificate_id: nil)
  end
end
