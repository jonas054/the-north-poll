require 'digest/sha1'

class Poll < ApplicationRecord
  has_many :votes, dependent: :destroy
  belongs_to :scale

  SECRET = 432_473_648

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
    res = current_votes.group_by(&:content)
    if can_have_average?
      Hash[*res.sort_by { |k, _| number?(k) ? to_number(k) : 1_000_000_000 }
               .flatten(1)]
    else
      res
    end
  end

  def can_have_average?
    current_votes.count { |vote| number?(vote.content) } > 1
  end

  def standard_deviation
    avg = average
    Math.sqrt(mapped_mean { |v| (to_number(v.content) - avg)**2 })
  end

  def average
    mapped_mean { |v| to_number(v.content) }
  end

  delegate :choices, to: :scale

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

  # Remove old polls with only old votes. Also remove scales that are
  # no longer used.
  def self.remove_old
    age_limit = 1.month.ago
    oldest = all.select do |poll|
      poll.updated_at < age_limit &&
        poll.votes.all? { |vote| vote.updated_at < age_limit }
    end

    oldest.each do |old|
      old.remove_links_to
      old.scale.destroy if old.scale&.polls == [old]
      old.destroy
    end
  end

  private

  def set_to_nil(linked_id, key)
    Poll.update(linked_id, key => nil) if linked_id && Poll.exists?(linked_id)
  end

  def mapped_mean(&block)
    numerical_votes.map(&block).reduce(0.0, :+) / numerical_votes.size
  end

  def numerical_votes
    current_votes.select { |v| number?(v.content) }
  end

  def number?(string)
    string =~ /\d+/
  end
end
