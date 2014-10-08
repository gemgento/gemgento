ActiveAdmin.setup do |config|
  config.site_title = 'Gemgento'
  config.authentication_method = :authenticate_admin_user!
  config.current_user_method = :current_admin_user
  config.logout_link_path = :destroy_admin_user_session_path
  config.root_to = 'admin_users#index'
  config.batch_actions = true

  config.clear_stylesheets!
  config.register_stylesheet 'gemgento/active_admin.css'

  config.clear_javascripts!
  config.register_javascript 'gemgento/active_admin.js'
end
