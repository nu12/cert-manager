class Certificate < ApplicationRecord
  belongs_to :user
  belongs_to :key
  belongs_to :certificate, optional: true
  has_many :children, class_name: "Certificate", foreign_key: "certificate_id"
  belongs_to :parent, class_name: "Certificate", foreign_key: "certificate_id", optional: true

  def is_valid?
    self.expired_at >= DateTime.now
  end
end
