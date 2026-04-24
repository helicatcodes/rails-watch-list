Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

# Defines the root path route ("/")
# root "posts#index"

# A user can see all the lists
get "lists", to: "lists#index", as: :lists

# # Optional: root path
# root to: "lists#index"

# A user can create a new list
get "lists/new", to: "lists#new", as: :new_list
post "lists", to: "lists#create"

# A user can see the details of a given list and its name.
# ":id" is a dynamic segment — Rails captures whatever number is in the URL
# (e.g. /lists/3) and makes it available as params[:id] in the controller.
# "to:" tells Rails which controller#action to call.
# "as:" gives this route a named helper (list_path(@list)) we use in views.
get "lists/:id", to: "lists#show", as: :list

post "bookmarks", to: "bookmarks#create", as: :bookmarks
end


# FAST WAY TO WRITE THE ROUTES/ CLASS SOLUTION

# Rails.application.routes.draw do
#   # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
#   root to: "lists#index"
#   resources :lists, except: [:edit, :update] do
#     resources :bookmarks, only: [:new, :create]
#     resources :reviews, only: :create
#   end
#   resources :bookmarks, only: :destroy
#   resources :reviews, only: :destroy
# end
