class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    def redirect_certificate(certificate)
      return redirect_to certificates_root_path(certificate), notice: "Root certificate was successfully created." if certificate.type == :root
      return redirect_to certificates_root_intermediate_path(certificate.parent, certificate), notice: "Intermediate certificate was successfully created." if certificate.type == :intermediate
      redirect_to certificates_root_intermediate_server_path(certificate.parent.parent, certificate.parent, certificate), notice: "Server certificate was successfully created." if certificate.type == :server
    end
end
