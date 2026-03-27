class Key < ApplicationRecord
  belongs_to :user
  has_many :certificates
end
