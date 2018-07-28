class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :nickname, :image])
  end

  def pagination_headers(pagy)
    response.headers['Total-Pages'] = pagy.pages.to_s
    response.headers['Per-Page'] = pagy.items.to_s if pagy.pages > 1
  end
end
