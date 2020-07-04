class VoteController < ApplicationController
  def create
    poll_id = params[:poll][:id]
    Vote.create! content: params[:vote][:value], poll_id: poll_id
    destination = { controller: 'poll', action: 'results', id: poll_id }
    if params[:poll][:editkey] == Poll.find(poll_id).editkey
      destination[:editkey] = params[:poll][:editkey]
    end
    redirect_to destination
  end
end
