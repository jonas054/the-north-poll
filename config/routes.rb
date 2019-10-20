Rails.application.routes.draw do
  get 'poll/new'
  get 'poll/:id/results', controller: 'poll', action: 'results'
  get 'poll/:id/results_async', controller: 'poll', action: 'results_async'
  get 'poll/create_linked/:id', controller: 'poll', action: 'create_linked'
  get 'poll/list/:id', controller: 'poll', action: 'list'
  get 'poll/list_async/:id', controller: 'poll', action: 'list_async'
  get 'vote/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'vote#index'
  get '/', to: 'vote#index'

  resources :poll, :vote
end
