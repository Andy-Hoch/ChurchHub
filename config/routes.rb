Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[ new create ]

  resource :hub, only: %i[ show edit update ] do
    get :embed
    post :regenerate_token
    resources :links, except: %i[ index show ] do
      put :position, on: :member
    end
  end

  resources :churches, only: %i[ new create ]
  resource :church, only: %i[ edit update ], controller: :current_church do
    resources :memberships, only: %i[ create destroy ]
  end
  resource :church_switch, only: :update

  get "embed/:token", to: "embed#show", as: :embed, format: true, constraints: { format: :js }

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"
end
