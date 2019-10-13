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
    @sum = @poll.votes.map { |v| v.content.to_i }.reduce(:+)
    @results = @poll.votes.group_by { |v| v.content.to_i }
    @average = @sum.to_f / @poll.votes.size
  end
end
