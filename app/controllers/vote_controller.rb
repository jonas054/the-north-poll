class VoteController < ApplicationController
  def index
    @hide_archived = params['hide_archived'] == 'true'
    @hide_empty = params['hide_empty'] == 'true'
    @chains = Poll.where(previous_poll_id: nil).map(&:find_chain).select do |chain|
      next true unless @hide_empty

      chain.any? { |poll| @hide_archived ? poll.current_votes.any? : poll.votes.any? }
    end
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
