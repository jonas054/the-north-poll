require 'digest/sha1'

class Poll < ApplicationRecord
  has_many :votes, dependent: :destroy
  belongs_to :scale

  SECRET = 432473648

  include ActionView::Helpers::TextHelper # pluralize()
  include PollHelper # to_number()

  def current_votes
    votes.where(is_archived: false)
  end

  def sum_up
    total = results.sort_by { |_, votes| -votes.size }.map do |key, votes|
      "#{key}: #{pluralize(votes.size, 'vote')}"
    end
    total.join(', ')
  end

  def editkey
    Digest::SHA1.hexdigest((key.to_i + SECRET).to_s)
  end

  def results
    if can_have_average?
      current_votes.group_by { |v| to_number(v.content) }
    else
      current_votes.group_by(&:content)
    end
  end

  def standard_deviation
    avg = average
    Math.sqrt(mapped_mean { |v| (v.content.to_f - avg)**2 })
  end

  def average
    mapped_mean { |v| v.content.to_f }
  end

  delegate :can_have_average?, :choices, to: :scale

  def chain
    if previous_poll_id
      Poll.find(previous_poll_id).chain + [self]
    else
      [self]
    end
  end

  def remove_links_to
    set_to_nil(previous_poll_id, :next_poll_id)
    set_to_nil(next_poll_id, :previous_poll_id)
  end

  private

  def set_to_nil(linked_id, key)
    Poll.update(linked_id, key => nil) if linked_id && Poll.exists?(linked_id)
  end

  def mapped_mean
    current_votes.map { |v| yield v }.reduce(0.0, :+) / current_votes.size
  end
end
