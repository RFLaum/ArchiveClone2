Rails.application.routes.draw do
  root 'special_pages#home'
  get 'home2' => 'special_pages#home2'
  get 'about' => 'special_pages#about', as: :about
  get 'tech' => 'special_pages#technical', as: :tech
  resources :newsposts do
    resources :news_comments
  end
  resources :tags do
    resources :stories, only: %i[index]
  end
  resources :characters do
    resources :stories, only: %i[index]
  end

  get 'sources/bulk_update' => 'sources#update_form'
  post 'sources/bulk_update' => 'sources#update_receiver'
  get 'sources/search' => 'sources#search_form'
  get 'sources/results' => 'sources#search_results'
  resources :sources do
    resources :stories, only: %i[index]
  end
  get 'sources/:type', to: 'sources#index_type', constraints: { type: /[a-z_]+/ }

  get 'stories/:id/chapters/all' => 'stories#showall'
  get 'stories/:id/all' => 'stories#showall'
  get 'stories/:id/navigate' => 'stories#navigate'
  # get 'stories/:id/tags' => 'stories#tag_list', constraints: lambda { |req| req.format == :json }
  # get 'stories/:id/chapters/:chapter_num' => 'stories#show_chapter'
  # get 'stories/:id/add_bookmark' => 'bookmarks#new'
  get 'stories/search' => 'stories#search'
  post 'stories/search_results' => 'stories#search_results'
  get 'stories/search_results' => 'stories#search_results'
  resources :stories do
    resources :chapters
    resources :comments
    resources :bookmarks, except: [:show]
  end
  resources :bookmarks, only: [:index]
  # resources :chapters, only: %i[index create]

  # get 'stories/:story_id/add' => 'chapters#new'
  # get 'stories/:story_id/edit_chapter/:chapter_num' => 'chapters#edit'
  # post 'stories/:story_id' => 'chapters#create'
  # match 'stories/:story_id/:chapter_num' => 'chapters#update', via: %i[patch put]

  # get '/user_confirm/:user_name/auth=:hash' => 'users#confirm'
  get 'users/:id/auth=:hash' => 'users#confirm'
  get 'login' => 'users#login'
  post 'login' => 'users#login_receiver'
  get 'register' => 'users#register'
  get 'logout' => 'users#logout'
  match 'users/:id/deactivate' => 'users#deactivate', via: %i[patch put]
  resources :users, except: [:new], constraints: { id: /[^\/]+/ } do
    member do
      get 'send_confirmation'
    end
    resources :bookmarks, except: %i[new create show]
  end
  # resources :bookmarks

  namespace :admin do
    resources :banned_addresses, only: %i[index destroy],
                                 constraints: { id: /[^\/]+/ }
  end

  if Rails.env.development?
    get 'comments' => 'comments#index_all'
  end

  get 'search' => 'search#full_form'
  get 'results' => 'search#results'

  # get 'autocomplete/tag' => 'auto_complete#tag'
  # get 'autocomplete/source' => 'auto_complete#source'
  # get 'autocomplete/character' => 'auto_complete#character'
  get 'autocomplete/:action' => 'auto_complete#%{action}'
end
