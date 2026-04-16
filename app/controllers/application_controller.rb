class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    def redirect_certificate(certificate, msg = nil, status = :see_other)
      return redirect_to root_path, notice: msg, status: status unless certificate
      return redirect_to certificates_root_path(certificate), notice: msg ? msg : "Root certificate was successfully created.", status: status if certificate.is_root?
      return redirect_to certificates_root_intermediate_path(certificate.parent, certificate), notice: msg ? msg : "Intermediate certificate was successfully created.", status: status if certificate.is_intermediate?
      redirect_to certificates_root_intermediate_server_path(certificate.parent.parent, certificate.parent, certificate), notice: msg ? msg : "Server certificate was successfully created.", status: status if certificate.is_server?
    end
end
