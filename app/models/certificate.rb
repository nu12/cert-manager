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
    key = self.key
    self.children.each { |c| c.destroy! }
    super

    key.destroy! if key.certificates.count == 0
  end
end
