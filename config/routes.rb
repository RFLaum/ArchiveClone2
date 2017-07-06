Rails.application.routes.draw do
  get 'tags/search' => 'tags#search'
  get 'tags/find' => 'tags#find'
  get 'tags/new' => 'tags#new'
  post 'tags' => 'tags#create'
  get 'tags/:name/works' => 'tags#show'
  get 'tags/:name/edit' => 'tags#edit'
  match 'tags/:name' => 'tags#update', via: %i[patch put]
  delete 'tags/:name/delete' => 'tags#delete'
  # resources :tags
  get 'stories/:id/chapters/all' => 'stories#showall'
  get 'stories/:id/all' => 'stories#showall'
  # get 'stories/:id/add' => 'stories#new_chapter'
  get 'stories/:id/chapters/:chapter_num' => 'stories#show'
  # get 'stories/:id/edit_chapter/:chapter_num' => 'stories#edit_chapter'
  # post 'stories/:id' => 'stories#create_chapter'
  # match 'stories/:id/:chapter_num' => 'stories#update_chapter', via: %i[patch put]
  resources :stories
  get 'stories/:id' => 'stories#show'
  get 'stories/:id/add' => 'chapters#new'
  get 'stories/:id/edit_chapter/:chapter_num' => 'chapters#edit'
  post 'stories/:id' => 'chapters#create'
  match 'stories/:id/:chapter_num' => 'chapters#update', via: %i[patch put]
  # get 'stories/new' => 'stories#new'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
