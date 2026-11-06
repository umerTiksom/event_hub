
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :auth do
        post "/login", to: "auth#login"
        post "/register", to: "auth#register"

        post "/forgot_password", to: "password_resets#create"
        post "/reset_password", to: "password_resets#update"
      end

      resource :me, only: [:show, :destroy], controller: "me" do
        resources :registrations, only: [:index]
      end

      resources :events do
        resources :registrations, only: [:create, :destroy]
      end

      resources :categories, only: [:index, :show]

      get "events/:event_id/registrations",
          to: "registrations#event_members"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
