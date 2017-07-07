Rails.application.routes.draw do
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
  get 'stories/:id/chapters/:chapter_num' => 'stories#show_chapter'
  resources :stories

  get 'stories/:story_id/add' => 'chapters#new'
  get 'stories/:story_id/edit_chapter/:chapter_num' => 'chapters#edit'
  post 'stories/:story_id' => 'chapters#create'
  match 'stories/:story_id/:chapter_num' => 'chapters#update', via: %i[patch put]
end
