class PollController < ApplicationController
  def create
    previous_poll_id = params.dig(:previous_poll, :id)
    params[:title].split(';').each do |title|
      @poll = create_with_link(title, previous_poll_id)
      previous_poll_id = @poll.id
    end
    redirect_to "/poll/create_linked/#{@poll.id}"
  end

  def create_linked
    @previous_poll = find_poll
  end

  def show
    do_housekeeping
    @poll = find_poll
  end

  def results
    @poll = find_poll
  end

  def single_results
    @poll = find_poll
    render partial: 'single_results'
  end

  def list
    @poll = find_poll
  end

  def total
    @all = find_poll.chain
    render partial: 'total'
  end

  private

  def find_poll
    Poll.find(params[:id])
  end

  def create_with_link(title, previous_poll_id)
    poll = Poll.create! title: title, previous_poll_id: previous_poll_id,
                        scale: get_scale(previous_poll_id)
    Poll.update previous_poll_id, next_poll_id: poll.id if previous_poll_id
    poll
  end

  def get_scale(previous_poll_id)
    if previous_poll_id
      Poll.find(previous_poll_id).scale
    else
      scale_value = params[:scale][:list]
      if scale_value == 'custom'
        scale_value = params[:custom_scale].split.join(',')
      end
      Scale.find_or_create_by(list: scale_value)
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
