class PollController < ApplicationController
  def create
    previous_poll_id =
      params[:previous_poll] ? params[:previous_poll][:id] : nil
    params[:title].split(';').each do |title|
      if previous_poll_id
        scale = Poll.find(previous_poll_id).scale
      else
        scale_value = params[:scale][:list]
        if scale_value == 'custom'
          scale_value = params[:custom_scale].split.join(',')
        end
        scale = Scale.find_by_list(scale_value) ||
                Scale.create!(list: scale_value)
      end
      @poll = Poll.create! title: title, previous_poll_id: previous_poll_id,
                           scale: scale
      if previous_poll_id
        Poll.update previous_poll_id, next_poll_id: @poll.id
      end
      previous_poll_id = @poll.id
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

  def list_async
    @all = Poll.find(params[:id]).chain
  end

  def list
    @all = Poll.find(params[:id]).chain
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
