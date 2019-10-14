class PollController < ApplicationController
  def create
    previous_poll_id = params[:previous_poll] ? params[:previous_poll][:id] : nil
    @poll = Poll.create! title: params[:title],
                         previous_poll_id: previous_poll_id
    if previous_poll_id
      Poll.update previous_poll_id, next_poll_id: @poll.id
    end
    redirect_to "/poll/create_linked/#{@poll.id}"
  end

  def create_linked
    @previous_poll = Poll.find(params[:id])
  end

  def show
    do_housekeeping
    @poll = Poll.find(params[:id])
  end

  def results
    @poll = Poll.find(params[:id])
  end

  # Remove oldest entries in the database, just so it doesn't grow too big on
  # Heroku.
  def do_housekeeping
    if Poll.all.size > 200
      oldest = Poll.order(:updated_at).limit(1).load.first
      oldest.remove_links_to
      oldest.destroy
      Vote.all.each { |vote| vote.destroy unless vote.poll }
    end
  end
end
