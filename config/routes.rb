Rails.application.routes.draw do
  get 'poll/new'
  get 'poll/:id/results', controller: 'poll', action: 'results'
  get 'vote/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'vote#index'

  resources :poll, :vote
end
