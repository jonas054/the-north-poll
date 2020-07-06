Rails.application.routes.draw do
  get 'go', controller: 'poll', action: 'go'
  post 'poll/get'
  get 'poll/new'
  get 'poll/:id/results', controller: 'poll', action: 'results'
  get 'poll/:id/single_results', controller: 'poll', action: 'single_results'
  get 'poll/create_linked/:id', controller: 'poll', action: 'create_linked'
  get 'poll/list/:id', controller: 'poll', action: 'list'
  get 'poll/total/:id', controller: 'poll', action: 'total'
  post 'poll/:id/title', controller: 'poll', action: 'set_title'
  get 'poll/title/:id', controller: 'poll', action: 'title'
  get 'poll/skip/:id', controller: 'poll', action: 'skip'
  get 'vote/index'
  root 'poll#go'

  resources :poll, :vote
end
