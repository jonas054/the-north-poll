class VoteController < ApplicationController
  def create
    poll_id = params[:poll][:id]
    Vote.create! content: params[:vote][:value], poll_id: poll_id
    redirect_to "/poll/#{poll_id}/results"
  end

  def full
  end
end
