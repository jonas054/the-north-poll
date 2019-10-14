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
    @poll = Poll.find(params[:id])
  end

  def results
    @poll = Poll.find(params[:id])
  end
end
