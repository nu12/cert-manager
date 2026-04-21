class Key < ApplicationRecord
  belongs_to :user
  has_many :certificates
  has_encrypted :content

  after_create :set_content

  def pem
    CertManager::Key.parse(self).to_pem
  end

  private
    def set_content
      self.content = CertManager::Key.create(Rails.configuration.key_size)
      self.save
    end
end
