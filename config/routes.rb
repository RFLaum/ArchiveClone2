Rails.application.routes.draw do
  root 'special_pages#home'
  resources :newsposts
  get 'tags/search' => 'tags#search'
  get 'tags/find' => 'tags#find'
  get 'tags/new' => 'tags#new'
  post 'tags' => 'tags#create'
  get 'tags/:name/works' => 'tags#show'
  get 'tags/:name/edit' => 'tags#edit'
  match 'tags/:name' => 'tags#update', via: %i[patch put]
  delete 'tags/:name/delete' => 'tags#delete'
  resources :tags

  get 'stories/:id/chapters/all' => 'stories#showall'
  get 'stories/:id/all' => 'stories#showall'
  # get 'stories/:id/chapters/:chapter_num' => 'stories#show_chapter'
  resources :stories do
    resources :chapters
    resources :comments
  end

  # get 'stories/:story_id/add' => 'chapters#new'
  # get 'stories/:story_id/edit_chapter/:chapter_num' => 'chapters#edit'
  # post 'stories/:story_id' => 'chapters#create'
  # match 'stories/:story_id/:chapter_num' => 'chapters#update', via: %i[patch put]

  # get '/user_confirm/:user_name/auth=:hash' => 'users#confirm'
  get 'users/:user_name/auth=:hash' => 'users#confirm'
  get 'login' => 'users#login'
  post 'login' => 'users#login_receiver'
  get 'register' => 'users#register'
  get 'logout' => 'users#logout'
  resources :users, except: [:new]

  if Rails.env.development?
    get 'comments' => 'comments#index_all'
  end
end
