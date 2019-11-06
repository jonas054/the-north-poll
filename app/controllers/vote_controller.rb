class VoteController < ApplicationController
  def create
    poll_id = params[:poll][:id]
    Vote.create! content: params[:vote][:value], poll_id: poll_id
    redirect_to controller: 'poll', action: 'results', id: poll_id
  end
end
