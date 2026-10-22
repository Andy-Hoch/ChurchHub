Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[ new create ]
  resource :account, only: %i[ edit destroy ] do
    resource :password, only: :update, module: :accounts
  end

  resource :hub, only: %i[ show edit update ] do
    get :embed
    post :regenerate_token
    resources :links, except: %i[ index show ] do
      put :position, on: :member
    end
  end

  resources :forms do
    resource :availability, only: %i[ edit update ], controller: :form_availabilities
    resources :questions, controller: :form_questions, except: %i[ index show ] do
      put :position, on: :member
    end
    resources :submissions, controller: :form_submissions, only: %i[ index show destroy ] do
      patch :toggle_read, on: :member
      delete :destroy_all, on: :collection
    end
  end

  resources :churches, only: %i[ new create ]
  resource :church, only: %i[ edit update destroy ], controller: :current_church do
    resources :memberships, only: %i[ create update destroy ]
  end
  resource :church_switch, only: :update

  get "embed/:token", to: "embed#show", as: :embed, format: true, constraints: { format: :js }
  post "embed/:token/forms/:form_id/submissions", to: "embed_submissions#create", as: :embed_form_submissions

  post "csp-reports", to: "csp_reports#create", as: :csp_reports

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#home"

  # Must stay last: catches /<kirchenname> for the public hub page.
  get ":slug", to: "public_hubs#show", as: :public_hub, constraints: { slug: Church::SLUG_FORMAT }
end
