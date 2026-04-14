class Key < ApplicationRecord
  belongs_to :user
  has_many :certificates

  def self.create size, password, user
    create!(content: CertManager::Key.create(size, password), user: user)
  end
end
