Rails.application.routes.draw do
  get 'go', controller: 'poll', action: 'go'
  post 'poll/get'
  get 'poll/new'
  get 'poll/:id/results', controller: 'poll', action: 'results'
  get 'poll/:id/single_results', controller: 'poll', action: 'single_results'
  get 'poll/create_linked/:id', controller: 'poll', action: 'create_linked'
  get 'poll/list/:id', controller: 'poll', action: 'list'
  get 'poll/total/:id', controller: 'poll', action: 'total'
  get 'vote/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root 'vote#index'
  get '/', to: 'vote#index'

  resources :poll, :vote
end
