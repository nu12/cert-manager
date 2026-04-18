class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    def redirect_certificate(certificate, flash)
      return redirect_to root_path, flash unless certificate
      return redirect_to certificates_root_path(certificate.serial), flash if certificate.is_root?
      return redirect_to certificates_root_intermediate_path(certificate.parent.serial, certificate.serial), flash if certificate.is_intermediate?
      redirect_to certificates_root_intermediate_server_path(certificate.parent.parent.serial, certificate.parent.serial, certificate.serial), flash if certificate.is_server?
    end
end
