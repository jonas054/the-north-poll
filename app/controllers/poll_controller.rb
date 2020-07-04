class PollController < ApplicationController
  SITE = 'the-north-poll.herokuapp.com'.freeze

  before_action :validate_params, only: [:create]
  before_action :do_housekeeping, only: [:create]
  before_action :archive_old_votes, only: [:show]

  def index
  end

  def go
  end

  def get
    key = params[:code]
    poll = Poll.find_by(key: key)
    redirect_to "/poll/#{poll.id}?key=#{key}"
  end

  def create
    previous_poll_id = params.dig(:previous_poll, :id)

    if flash[:error]
      redirect_to creation_error_destination(previous_poll_id)
      return
    end

    params[:title].split(';').each do |title|
      @poll = create_with_link(title, previous_poll_id)
      previous_poll_id = @poll.id
    end
    redirect_to "/poll/create_linked/#{@poll.id}?key=#{@poll.key}"
  end

  def create_linked
    @previous_poll = find_poll
    render 'authorization_error' if params[:key] != @previous_poll.key
  end

  def results
    find_current_and_next
  end

  def single_results
    @poll = find_poll
    render partial: 'single_results'
  end

  alias list results

  def show
    find_current_and_next
    if params[:key] != @poll.key
      render 'authorization_error'
    elsif params.key?(:qr)
      url = "https://#{SITE}/poll/#{@poll.id}?qr&key=#{@poll.key}"
      @chart = GoogleQR.new(data: url, size: '500x500', margin: 4,
                            error_correction: 'L').to_s
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
    elsif params[:custom_scale].blank? &&
          params.dig(:scale, :list) == 'custom'
      flash[:error] = {
        field: 'custom_scale',
        text: 'Custom scale selected but not filled in'
      }
    elsif params[:title].blank?
      flash[:error] = { field: 'title', text: 'No title given' }
    end
  end

  def find_current_and_next
    @poll = find_poll
    @next_poll = Poll.find(@poll.next_poll_id) if @poll&.next_poll_id
  end

  def find_poll
    Poll.find(params[:id])
  end

  def create_with_link(title, previous_poll_id)
    poll = Poll.create!(title: title, previous_poll_id: previous_poll_id,
                        scale: get_scale(previous_poll_id),
                        key: rand(1e4).to_s)
    Poll.update previous_poll_id, next_poll_id: poll.id if previous_poll_id
    poll
  end

  def get_scale(previous_poll_id)
    if previous_poll_id
      Poll.find(previous_poll_id).scale
    else
      scale_value = params[:scale][:list]
      if scale_value == 'custom'
        scale_value = Scale.encode(params[:custom_scale])
      end
      Scale.find_or_create_by(list: scale_value)
    end
  end

  # Remove old polls with only old votes. Also remove scales that are
  # no longer used.
  def do_housekeeping
    age_limit = 1.month.ago
    oldest = Poll.all.select do |poll|
      poll.updated_at < age_limit &&
        poll.votes.all? { |vote| vote.updated_at < age_limit }
    end

    oldest.each do |old|
      old.remove_links_to
      old.scale.destroy if old.scale&.polls == [old]
      old.destroy
    end
  end

  def archive_old_votes
    Vote.all.where(["updated_at < ?", 3.days.ago]).each do |vote|
      vote.is_archived = true
      vote.save
    end
  end
end
