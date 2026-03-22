class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private
    def certificate_params
      params.expect([ :country, :state, :location, :organization, :organization_unit, :common_name, :key_size, :validity ])
      @authority_password = params[:authority_password]
      @c = params[:country]
      @st = params[:state]
      @l = params[:location]
      @o = params[:organization]
      @ou = params[:organization_unit]
      @cn = params[:common_name]
      @size = params[:key_size]
      @password = params[:password]
      @validity = params[:validity]
    end
end
