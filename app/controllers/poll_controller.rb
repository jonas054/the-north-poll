class PollController < ApplicationController
  before_action :validate_params, only: [:create]

  def create
    do_housekeeping

    previous_poll_id = params.dig(:previous_poll, :id)

    if flash[:error]
      redirect_to creation_error_destination(previous_poll_id)
      return
    end

    params[:title].split(';').each do |title|
      @poll = create_with_link(title, previous_poll_id)
      previous_poll_id = @poll.id
    end
    redirect_to "/poll/create_linked/#{@poll.id}"
  end

  def create_linked
    @previous_poll = find_poll
  end

  def results
    @poll = find_poll
  end

  def single_results
    @poll = find_poll
    render partial: 'single_results'
  end

  alias list results

  def show
    @poll = find_poll
    url = "https://the-north-poll.herokuapp.com/poll/#{@poll.id}"
    if params.key?(:qr)
      @chart = GoogleQR.new(:data => url, :size => "500x500", :margin => 4,
                            :error_correction => "L").to_s
    end
  end

  def total
    @all = find_poll.chain
    render partial: 'total'
  end

  private

  def creation_error_destination(previous_poll_id)
    if previous_poll_id
      "/poll/create_linked/#{previous_poll_id}"
    else
      '/?' + %w[title custom_scale].map do |key|
        "#{key}=#{params[key.to_sym]}"
      end.join('&')
    end
  end

  def validate_params
    if params[:custom_scale].present? && params[:scale][:list] != 'custom'
      flash[:error] = {
        field: 'custom_scale',
        text: 'Custom scale filled in but not selected'
      }
    elsif params[:title].blank?
      flash[:error] = { field: 'title', text: 'No title given' }
    end
  end

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
    oldest.scale.destroy if oldest.scale&.polls == [oldest]
    oldest.destroy
  end
end
