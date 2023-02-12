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

  def find_chain
    next_poll_id ? Poll.find(next_poll_id).find_chain : chain
  end

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

  # Removes old polls with only old votes unless they are chained to newer
  # polls. Also removes scales that are no longer used.
  def self.remove_old
    oldest = all.select { |poll| poll.old? && poll.chained_to_old? }

    oldest.each do |old|
      old.remove_links_to
      old.scale.destroy if old.scale&.polls == [old]
      old.destroy
    end
  end

  def chained_to_old?
    (next_poll.nil? || next_poll.old?) && (previous_poll.nil? || previous_poll.old?)
  end

  def next_poll
    next_poll_id ? Poll.find(next_poll_id) : nil
  end

  def previous_poll
    previous_poll_id ? Poll.find(previous_poll_id) : nil
  end

  def old?
    updated_at < 1.month.ago && votes.all? { _1.old? }
  end

  def self.reset_to_alphabetical
    where(previous_poll_id: nil).each do |poll|
      next if poll.title == 'A' || !poll.resettable_series?

      new_title = 'A'
      until poll.title == new_title
        poll.title = new_title
        poll.save
        break unless poll.next_poll_id

        poll = Poll.find(poll.next_poll_id)
        new_title = new_title.succ
      end
    end
  end

  def resettable_series?
    whole_chain = find_chain
    alphabet = ('A'..'Z').to_a[0, whole_chain.size]
    whole_chain.map(&:title) != alphabet &&
      ends_alphabetically?(whole_chain, alphabet) &&
      !has_current_votes?(whole_chain) &&
      !updated_recently?(whole_chain)
  end

  private

  def ends_alphabetically?(whole_chain, alphabet)
    whole_chain.last(3).map(&:title) == alphabet.last(3)
  end

  def has_current_votes?(whole_chain)
    whole_chain.map(&:current_votes).flatten.any?
  end

  def updated_recently?(whole_chain)
    whole_chain.none? { |poll| poll.updated_at < 12.hours.ago }
  end

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
