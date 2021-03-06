Rails.application.routes.draw do

  root 'posts#index'

  devise_for :users

  resources :users, only: [:index, :show]
  resources :posts, only: [:index, :create] do
    resources :comments, only: [:create]
    resources :likes, only: [:create, :destroy]
  end
  get 'sent_invitation/:requested_id', to:'users#request_friendship'
  get 'pending_invitations', to:'users#pending_invitations'
  get 'accept_invitation/:user_id', to:'users#accept_invitation'
  delete 'reject_invitation/:user_id', to:'users#reject_invitation'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
