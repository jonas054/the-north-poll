require 'rqrcode'

class PollController < ApplicationController
  before_action :validate_params, only: [:create]
  before_action :do_housekeeping, only: [:create]
  before_action :archive_old_votes, only: %i[show create_linked]
  before_action :reset_to_alphabetical, only: %i[show create_linked]

  def index
  end

  def go
  end

  def get
    key = params[:code]
    poll = Poll.find_by(key:)
    redirect_to "/poll/#{poll.id}?key=#{key}"
  end

  def show
    find_current_and_next
    if params[:key] != @poll.key
      render 'authorization_error'
    elsif params.key?(:qr)
      @chart = qr_code
    end
    choices = @poll.choices
    if choices.size > 5 && choices.all? { |choice| choice.chars.length < 6 }
      @choices_class = 'two-columns'
    end
    @edit_mode = params[:editkey] == @poll.editkey
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
    @poll = find_poll
    @vote = params[:vote]
    @edit_mode = params[:editkey] == @poll.editkey
  end

  def single_results
    find_current_and_next
    @vote = params[:vote]
    @edit_mode = params[:editkey] == @poll.editkey
    render partial: 'single_results'
  end

  def title
    @poll = find_poll
    @edit_mode = params[:editkey] == @poll.editkey
    render partial: 'title'
  end

  def skip
    find_current_and_next
    @edit_mode = params[:editkey] == @poll.editkey
    render partial: 'skip'
  end

  alias list results

  def set_title
    @poll = find_poll
    Poll.update params[:id], title: params[:title]
    redirect_to "/poll/#{@poll.id}?key=#{@poll.key}&editkey=#{@poll.editkey}"
  end

  def total
    @all = find_poll.chain
    render partial: 'total'
  end

  private

  def qr_code
    url =
      "#{request.protocol}#{request.host_with_port}/poll/#{@poll.id}?qr&key=#{@poll.key}"

    # Rickrolling easter egg.
    url = 'https://tinyurl.com/yckkezm3' if @poll.title == 'RA-1234'

    RQRCode::QRCode.new(url)
  end

  def creation_error_destination(previous_poll_id)
    if previous_poll_id
      previous_poll = Poll.find(previous_poll_id)
      "/poll/create_linked/#{previous_poll_id}?key=#{previous_poll.key}"
    else
      '/poll?' + # rubocop:disable Style/StringConcatenation
        %w[title custom_scale].map { |key| "#{key}=#{params[key.to_sym]}" }.join('&')
    end
  end

  def validate_params
    if params[:custom_scale].present? && params[:scale][:list] != 'custom'
      flash[:error] =
        { field: 'custom_scale', text: 'Custom scale filled in but not selected' }
    elsif params[:custom_scale].blank? && params.dig(:scale, :list) == 'custom'
      flash[:error] =
        { field: 'custom_scale', text: 'Custom scale selected but not filled in' }
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
    poll = Poll.create!(title:, previous_poll_id:,
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
      scale_value = Scale.encode(params[:custom_scale]) if scale_value == 'custom'
      Scale.find_or_create_by(list: scale_value)
    end
  end

  def do_housekeeping
    Poll.remove_old
    Vote.remove_old
  end

  def reset_to_alphabetical
    Poll.reset_to_alphabetical
  end

  def archive_old_votes
    Vote.all.where(['updated_at < ?', 12.hours.ago]).each do |vote|
      vote.is_archived = true
      vote.save
    end
  end
end
