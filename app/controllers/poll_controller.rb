class PollController < ApplicationController
  def create # rubocop:disable Metrics/MethodLength
    previous_poll_id =
      params[:previous_poll] ? params[:previous_poll][:id] : nil
    for title in params[:title].split(';') # rubocop:disable Style/For
      scale = get_scale(previous_poll_id)
      @poll = Poll.create! title: title, previous_poll_id: previous_poll_id,
                           scale: scale
      poll_id = @poll.id
      Poll.update previous_poll_id, next_poll_id: poll_id if previous_poll_id
      previous_poll_id = poll_id
    end
    redirect_to "/poll/create_linked/#{poll_id}"
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

  private

  def get_scale(previous_poll_id)
    if previous_poll_id
      Poll.find(previous_poll_id).scale
    else
      scale_value = params[:scale][:list]
      if scale_value == 'custom'
        scale_value = params[:custom_scale].split.join(',')
      end
      Scale.find_by(list: scale_value) || Scale.create!(list: scale_value)
    end
  end

  # Remove oldest entries in the database, just so it doesn't grow too big on
  # Heroku.
  def do_housekeeping
    return if Poll.count < 200

    oldest = Poll.order(:updated_at).limit(1).load.first
    oldest.remove_links_to
    oldest.destroy
    Vote.all.each { |vote| vote.destroy unless vote.poll }
  end
end
