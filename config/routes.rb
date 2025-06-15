Rails.application.routes.draw do
  post 'send_line_message', to: 'line_messages#send_message'

  get 'line_login_api/login', to: 'line_login_api#login'
  get 'line_login_api/callback', to: 'line_login_api#callback'

  get 'home', to: 'home#index'

  get 'login', to: 'user_sessions#new'
  post 'login', to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy'

  root 'user_sessions#new'
end
