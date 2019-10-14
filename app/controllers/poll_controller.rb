class PollController < ApplicationController
  def create
    @poll = Poll.create! title: params[:title]
    redirect_to "/poll/#{@poll.id}"
  end

  def show
    @poll = Poll.find(params[:id])
  end

  def results
    @poll = Poll.find(params[:id])
  end
end
