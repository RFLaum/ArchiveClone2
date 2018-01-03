Rails.application.routes.draw do
  # root 'special_pages#home'
  root 'special_pages#home2'
  get 'home' => 'special_pages#home2', as: :home
  get 'home2' => 'special_pages#home2' #, as: :home
  get 'home3' => 'special_pages#home'
  get 'about' => 'special_pages#about', as: :about
  get 'tech' => 'special_pages#technical', as: :tech
  resources :newsposts do
    resources :news_comments
  end
  resources :news_tags do
    resources :newsposts, only: %i[index]
  end
  get 'tags/:id/add' => 'tags#add_fave', as: :add_fave #, constraints: { id: /[^\/]+/ }
  get 'tags/:id/remove' => 'tags#remove_fave', as: :remove_fave #, constraints: { id: /[^\/]+/ }
  resources :tags do #, constraints: { id: /[^\/]+/ } do
    resources :stories, only: %i[index]
  end
  resources :characters do
    resources :stories, only: %i[index]
  end

  get 'sources/bulk_update' => 'sources#update_form', as: :bulk
  post 'sources/bulk_update' => 'sources#update_receiver'
  get 'sources/search' => 'sources#search_form', as: :source_search
  get 'sources/results' => 'sources#search_results'
  resources :sources, only: [:new] #, constraints: { id: /[^\/]+/ }
  get 'sources/:type', to: 'sources#index_type', constraints: { type: /[a-z_]+/ }, as: :type
  resources :sources do
    resources :stories, only: %i[index]
  end

  get 'stories/:id/chapters/all' => 'stories#showall'
  get 'stories/:id/all' => 'stories#showall', as: :story_all
  get 'stories/:id/navigate' => 'stories#navigate', as: :chap_nav
  # get 'stories/:id/tags' => 'stories#tag_list', constraints: lambda { |req| req.format == :json }
  # get 'stories/:id/chapters/:chapter_num' => 'stories#show_chapter'
  # get 'stories/:id/add_bookmark' => 'bookmarks#new'
  get 'stories/search' => 'stories#search', as: :story_search
  post 'stories/search_results' => 'stories#search_results'
  get 'stories/search_results' => 'stories#search_results', as: :story_s_res
  resources :stories do
    member do
      post 'multi_update'
    end
    resources :chapters do
      # collection do
      member do
        if Rails.env.development? || ENV["MULTI_CHAPTER_UPDATE"]
          get 'multi_update'
          # post 'multi_update' => 'stories#multi_receiver'
        end
      end
    end
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
  get 'users/:id/auth=:hash' => 'users#confirm', constraints: { id: /[^\/]+/ }
  get 'login' => 'users#login', as: :login
  post 'login' => 'users#login_receiver'
  get 'register' => 'users#register', as: :register
  get 'logout' => 'users#logout', as: :logout
  match 'users/:id/deactivate' => 'users#deactivate', via: %i[patch put], as: :deactivate #, constraints: { id: /[^\/]+/ }
  delete 'users/:id/ban' => 'users#ban', as: :ban #, constraints: { id: /[^\/]+/ }
  get 'faves' => 'users#faves', as: :faves
  get 'users/:id/subscribe' => 'users#subscribe', as: :subscribe #, constraints: { id: /[^\/]+/ }
  get 'users/:id/unsubscribe' => 'users#unsubscribe', as: :unsubscribe #, constraints: { id: /[^\/]+/ }
  get 'users/subs', as: :subs
  get 'users/forgot_password' => 'users#forgot', as: :forgot
  post 'users/forgot_password' => 'users#forgot_receiver'
  post 'users/:id/:conf' => 'users#reset_receiver', as: :reset_pw
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

  # if Rails.env.development?
  #   get 'comments' => 'comments#index_all'
  # end

  get 'search' => 'search#full_form', as: :search
  get 'results' => 'search#results'

  # get 'autocomplete/tag' => 'auto_complete#tag'
  # get 'autocomplete/source' => 'auto_complete#source'
  # get 'autocomplete/character' => 'auto_complete#character'
  get 'autocomplete/:action' => 'auto_complete#%{action}', as: :ac
end
