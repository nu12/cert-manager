class Key < ApplicationRecord
  belongs_to :user
  has_many :certificates

  def self.create(size, user)
    create!(content: CertManager::Key.create(size), user: user)
  end
end
