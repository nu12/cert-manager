class Certificate < ApplicationRecord
  belongs_to :user
  belongs_to :key
  belongs_to :certificate
  has_many :children, class_name: "Certificate", foreign_key: "certificate_id"
  belongs_to :parent, class_name: "Certificate", foreign_key: "certificate_id", optional: true
end
   