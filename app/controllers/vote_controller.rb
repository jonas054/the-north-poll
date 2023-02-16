class VoteController < ApplicationController
  def index
    @chains = Poll.where(previous_poll_id: nil).map(&:find_chain)
    @hide_archived = params['hide_archived'] == 'true'
  end

  def create
    poll_id = params[:poll][:id]
    vote = params[:vote][:value]
    Vote.create!(content: vote, poll_id:)
    destination = { controller: 'poll', action: 'results', id: poll_id, vote: }
    if params[:poll][:editkey] == Poll.find(poll_id).editkey
      destination[:editkey] = params[:poll][:editkey]
    end
    redirect_to destination
  end
end
