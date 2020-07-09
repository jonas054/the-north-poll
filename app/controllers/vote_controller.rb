class VoteController < ApplicationController
  def create
    poll_id = params[:poll][:id]
    Vote.create! content: params[:vote][:value], poll_id: poll_id
    destination = { controller: 'poll', action: 'results', id: poll_id }
    destination[:editkey] = params[:poll][:editkey] if params[:poll][:editkey] == Poll.find(poll_id).editkey
    redirect_to destination
  end
end
