Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'
  
  namespace :v1 do
    resources :tasks
    resources :tags, only: [:index, :show]
    get '/archived' => 'tasks#index_archived_tasks'
  end
end
