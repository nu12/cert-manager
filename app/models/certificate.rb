class Certificate < ApplicationRecord
  belongs_to :user
  belongs_to :key
  belongs_to :certificate, optional: true
  has_many :children, class_name: "Certificate", foreign_key: "certificate_id"
  belongs_to :parent, class_name: "Certificate", foreign_key: "certificate_id", optional: true

  after_create :set_subject

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

  private
    def set_subject
      raw = CertManager::Certificate.parse(self)
      self.subject = raw.subject_key_identifier.unpack("H*").first.upcase.chars.each_slice(2).map(&:join).join(":")
    end
end
