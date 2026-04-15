class Key < ApplicationRecord
  belongs_to :user
  has_many :certificates

  after_create :set_content

  private
    def set_content
      self.content = CertManager::Key.create(Rails.configuration.key_size)
      self.save
    end
end
