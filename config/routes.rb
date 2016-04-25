Rails.application.routes.draw do
  resources :projects do
    post :toggle_state, on: :member
    post :archive, on: :member
    get "history" => "project_history#index", on: :member
  end

  resources :project_checks do
    post :toggle_state
    post :override_deadline
    get :pick_person
    post :reassign_person
    post :assign_checker
    get "history" => "checks_history#index", on: :member
    get :complete_check, to: "check_assignments#complete_check"
    post :confirm_check, to: "check_assignments#confirm_check"
  end

  post "check_assignments/set_deadline" => "check_assignments#set_deadline", as: :set_deadline

  resources :reminders do
    post :sync_projects
  end

  resources :skills, only: [:index] do
    post :toggle, on: :collection
  end

  resources :users, only: [:index, :show] do
    post :toggle_admin, on: :member
    post :toggle_paused_by_user, on: :member
    post :toggle_paused, on: :member
  end

  root to: "visitors#index"

  namespace :admin do
    resources :users do
      resources :skills, only: [:index] do
        post :toggle, on: :collection
      end
    end

    resources :project_checks, only: [] do
      resources :check_assignments, only: [:create, :destroy]
    end
  end

  get "/auth/:provider/callback" => "sessions#create"
  get "/signin" => "sessions#new", as: :signin
  get "/signout" => "sessions#destroy", as: :signout
  get "/auth/failure" => "sessions#failure"
end
