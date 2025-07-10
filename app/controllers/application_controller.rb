class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern  # Comentado temporariamente - causa problemas com requisições AJAX
  
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :role, :active])
  end
  
  private
  
  def ensure_admin!
    redirect_to root_path, alert: 'Acesso negado.' unless current_user&.admin?
  end
  
  def ensure_manager_or_admin!
    redirect_to root_path, alert: 'Acesso negado.' unless current_user&.can_manage?
  end
end
